import XCTest
@testable import BudgetCore

final class BudgetCoreTests: XCTestCase {
    func testAddAccountAndTransaction() throws {
        let temp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let store = try BudgetStore(directoryURL: temp)

        let account = Account(name: "Test", type: .checking)
        try store.addAccount(account)
        XCTAssertEqual(store.accounts().count, 1)

        let tx = Transaction(date: Date(), amountInCents: -1234, payee: "Coffee Shop", categoryId: nil, accountId: account.id)
        try store.addTransaction(tx)

        XCTAssertEqual(store.transactions().count, 1)
        XCTAssertEqual(store.accounts().first?.balanceCents, -1234)
    }
}