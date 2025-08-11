import Foundation

public struct Transaction: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var date: Date
    public var amountInCents: Int
    public var payee: String
    public var memo: String?
    public var categoryId: UUID?
    public var accountId: UUID
    public var isTransfer: Bool
    public var recurrence: Recurrence?

    public init(
        id: UUID = UUID(),
        date: Date,
        amountInCents: Int,
        payee: String,
        memo: String? = nil,
        categoryId: UUID? = nil,
        accountId: UUID,
        isTransfer: Bool = false,
        recurrence: Recurrence? = nil
    ) {
        self.id = id
        self.date = date
        self.amountInCents = amountInCents
        self.payee = payee
        self.memo = memo
        self.categoryId = categoryId
        self.accountId = accountId
        self.isTransfer = isTransfer
        self.recurrence = recurrence
    }
}