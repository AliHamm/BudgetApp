import Foundation

public enum BudgetStoreError: Error, LocalizedError {
    case accountNotFound
    case categoryNotFound
    case transactionNotFound
    case ioError(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .accountNotFound: return "Account not found"
        case .categoryNotFound: return "Category not found"
        case .transactionNotFound: return "Transaction not found"
        case .ioError(let underlying): return "I/O error: \(underlying.localizedDescription)"
        }
    }
}

public struct BudgetData: Codable, Sendable {
    public var accounts: [Account]
    public var categories: [Category]
    public var transactions: [Transaction]

    public init(accounts: [Account] = [], categories: [Category] = [], transactions: [Transaction] = []) {
        self.accounts = accounts
        self.categories = categories
        self.transactions = transactions
    }
}

public final class BudgetStore: @unchecked Sendable {
    private let directoryURL: URL
    private let fileURL: URL

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private let queue = DispatchQueue(label: "BudgetStoreQueue", qos: .userInitiated)
    private var data: BudgetData

    public init(directoryURL: URL) throws {
        self.directoryURL = directoryURL
        self.fileURL = directoryURL.appendingPathComponent("budget.json")

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.data = BudgetData()

        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try load()
    }

    public static func defaultStorageDirectory(appFolderName: String = "BudgetData") -> URL {
        #if os(iOS)
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        #elseif os(macOS)
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        #else
        let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        #endif
        return base.appendingPathComponent(appFolderName, isDirectory: true)
    }

    public func load() throws {
        try queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return
            }
            do {
                let data = try Data(contentsOf: fileURL)
                self.data = try decoder.decode(BudgetData.self, from: data)
            } catch {
                throw BudgetStoreError.ioError(underlying: error)
            }
        }
    }

    public func save() throws {
        try queue.sync {
            do {
                let data = try encoder.encode(self.data)
                try data.write(to: fileURL, options: [.atomic])
            } catch {
                throw BudgetStoreError.ioError(underlying: error)
            }
        }
    }

    // MARK: - Accounts

    public func accounts() -> [Account] { queue.sync { data.accounts } }

    @discardableResult
    public func addAccount(_ account: Account) throws -> Account {
        try queue.sync {
            data.accounts.append(account)
            try save()
            return account
        }
    }

    public func updateAccount(_ account: Account) throws {
        try queue.sync {
            guard let index = data.accounts.firstIndex(where: { $0.id == account.id }) else {
                throw BudgetStoreError.accountNotFound
            }
            data.accounts[index] = account
            try save()
        }
    }

    public func deleteAccount(id: UUID) throws {
        try queue.sync {
            guard let index = data.accounts.firstIndex(where: { $0.id == id }) else {
                throw BudgetStoreError.accountNotFound
            }
            // Also remove transactions related to this account
            data.transactions.removeAll { $0.accountId == id }
            data.accounts.remove(at: index)
            try save()
        }
    }

    // MARK: - Categories

    public func categories() -> [Category] { queue.sync { data.categories } }

    @discardableResult
    public func addCategory(_ category: Category) throws -> Category {
        try queue.sync {
            data.categories.append(category)
            try save()
            return category
        }
    }

    public func updateCategory(_ category: Category) throws {
        try queue.sync {
            guard let index = data.categories.firstIndex(where: { $0.id == category.id }) else {
                throw BudgetStoreError.categoryNotFound
            }
            data.categories[index] = category
            try save()
        }
    }

    public func deleteCategory(id: UUID) throws {
        try queue.sync {
            guard let index = data.categories.firstIndex(where: { $0.id == id }) else {
                throw BudgetStoreError.categoryNotFound
            }
            // Do not delete transactions, just unset their category
            for i in data.transactions.indices {
                if data.transactions[i].categoryId == id { data.transactions[i].categoryId = nil }
            }
            data.categories.remove(at: index)
            try save()
        }
    }

    // MARK: - Transactions

    public func transactions() -> [Transaction] { queue.sync { data.transactions.sorted { $0.date > $1.date } } }

    @discardableResult
    public func addTransaction(_ transaction: Transaction) throws -> Transaction {
        try queue.sync {
            guard let accountIndex = data.accounts.firstIndex(where: { $0.id == transaction.accountId }) else {
                throw BudgetStoreError.accountNotFound
            }
            data.transactions.append(transaction)
            // Update account balance
            data.accounts[accountIndex].balanceCents += transaction.amountInCents
            try save()
            return transaction
        }
    }

    public func updateTransaction(_ transaction: Transaction) throws {
        try queue.sync {
            guard let index = data.transactions.firstIndex(where: { $0.id == transaction.id }) else {
                throw BudgetStoreError.transactionNotFound
            }
            let old = data.transactions[index]
            // Revert old amount from old account balance
            if let oldAccountIndex = data.accounts.firstIndex(where: { $0.id == old.accountId }) {
                data.accounts[oldAccountIndex].balanceCents -= old.amountInCents
            }
            // Apply new amount to new account balance
            guard let newAccountIndex = data.accounts.firstIndex(where: { $0.id == transaction.accountId }) else {
                throw BudgetStoreError.accountNotFound
            }
            data.accounts[newAccountIndex].balanceCents += transaction.amountInCents

            data.transactions[index] = transaction
            try save()
        }
    }

    public func deleteTransaction(id: UUID) throws {
        try queue.sync {
            guard let index = data.transactions.firstIndex(where: { $0.id == id }) else {
                throw BudgetStoreError.transactionNotFound
            }
            let tx = data.transactions[index]
            if let accountIndex = data.accounts.firstIndex(where: { $0.id == tx.accountId }) {
                data.accounts[accountIndex].balanceCents -= tx.amountInCents
            }
            data.transactions.remove(at: index)
            try save()
        }
    }

    // MARK: - Analytics helpers

    public func totalSpentCents(inMonthOf date: Date = Date()) -> Int {
        let calendar = Calendar.current
        return queue.sync {
            data.transactions
                .filter { tx in
                    let comps = calendar.dateComponents([.year, .month], from: tx.date)
                    let target = calendar.dateComponents([.year, .month], from: date)
                    return comps.year == target.year && comps.month == target.month && tx.amountInCents < 0
                }
                .map { abs($0.amountInCents) }
                .reduce(0, +)
        }
    }

    public func totalIncomeCents(inMonthOf date: Date = Date()) -> Int {
        let calendar = Calendar.current
        return queue.sync {
            data.transactions
                .filter { tx in
                    let comps = calendar.dateComponents([.year, .month], from: tx.date)
                    let target = calendar.dateComponents([.year, .month], from: date)
                    return comps.year == target.year && comps.month == target.month && tx.amountInCents > 0
                }
                .map { $0.amountInCents }
                .reduce(0, +)
        }
    }

    // MARK: - Sample data

    public func seedSampleIfEmpty() throws {
        try queue.sync {
            guard data.accounts.isEmpty && data.categories.isEmpty && data.transactions.isEmpty else { return }
            let checking = Account(name: "Checking", type: .checking, balanceCents: 0)
            let groceries = Category(name: "Groceries", colorHex: "#34D399", budgetedCents: 40000, isExpense: true)
            let salaryCat = Category(name: "Salary", colorHex: "#60A5FA", budgetedCents: 0, isExpense: false)
            data.accounts = [checking]
            data.categories = [groceries, salaryCat]
            let salary = Transaction(date: Date(), amountInCents: 250000, payee: "Acme Corp", categoryId: salaryCat.id, accountId: checking.id, isTransfer: false)
            let food = Transaction(date: Date(), amountInCents: -7599, payee: "Supermarket", categoryId: groceries.id, accountId: checking.id, isTransfer: false)
            data.transactions = [salary, food]
            data.accounts[0].balanceCents = salary.amountInCents + food.amountInCents
            try save()
        }
    }
}