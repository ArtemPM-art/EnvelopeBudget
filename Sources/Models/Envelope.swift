import Foundation
import SwiftData

@Model
final class Envelope {
    var name: String
    var plannedAmount: Decimal

    /// Пока всегда 0 — ввода трат ещё нет.
    /// Со следующей стори станет суммой трат, привязанных к конверту.
    var spentAmount: Decimal

    var createdAt: Date

    init(name: String, plannedAmount: Decimal) {
        self.name = name
        self.plannedAmount = plannedAmount
        self.spentAmount = 0
        self.createdAt = .now
    }
}

extension Envelope {
    var remainingAmount: Decimal {
        plannedAmount - spentAmount
    }

    var isOverspent: Bool {
        remainingAmount < 0
    }

    /// Доля израсходованного от 0 до 1 — только для полоски.
    var spentFraction: Double {
        guard plannedAmount > 0 else {
            return spentAmount > 0 ? 1 : 0
        }
        let spent = NSDecimalNumber(decimal: spentAmount).doubleValue
        let planned = NSDecimalNumber(decimal: plannedAmount).doubleValue
        return min(max(spent / planned, 0), 1)
    }
}
