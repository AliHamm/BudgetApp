import Foundation

public enum Recurrence: String, Codable, CaseIterable, Sendable {
    case none
    case daily
    case weekly
    case biweekly
    case monthly
    case quarterly
    case yearly
}