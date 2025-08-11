import Foundation
import BudgetCore

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var categories: [Category] = []
    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?

    private var store: BudgetStore?

    init() {
        do {
            let dir = BudgetStore.defaultStorageDirectory()
            let store = try BudgetStore(directoryURL: dir)
            self.store = store
            try store.seedSampleIfEmpty()
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reload() {
        guard let store = store else { return }
        accounts = store.accounts()
        categories = store.categories()
        transactions = store.transactions()
    }

    func addAccount(name: String, type: AccountType) {
        guard let store = store else { return }
        do {
            let account = Account(name: name, type: type)
            try store.addAccount(account)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addSampleTransaction() {
        guard let store = store, let account = accounts.first else { return }
        do {
            let tx = Transaction(date: Date(), amountInCents: -1599, payee: "Sample Purchase", categoryId: categories.first?.id, accountId: account.id)
            try store.addTransaction(tx)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}