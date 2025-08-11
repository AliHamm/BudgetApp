import Foundation

public struct Category: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var colorHex: String
    public var budgetedCents: Int
    public var isExpense: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#6B7280",
        budgetedCents: Int = 0,
        isExpense: Bool = true
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.budgetedCents = budgetedCents
        self.isExpense = isExpense
    }
}