import Foundation

public enum AccountType: String, Codable, CaseIterable, Sendable {
    case checking
    case savings
    case creditCard
    case cash
    case investment
    case other
}

public struct Account: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var type: AccountType
    public var balanceCents: Int

    public init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        balanceCents: Int = 0
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balanceCents = balanceCents
    }
}