import Foundation
import SwiftData

@Model
final class Envelope {
    var name: String
    var plannedAmount: Decimal
    var createdAt: Date

    /// Категория по умолчанию для новых трат. Одновременно true — только у одного конверта.
    var isDefault: Bool = false

    /// Траты, привязанные к конверту. Удаление конверта уносит и его траты.
    @Relationship(deleteRule: .cascade, inverse: \Spend.envelope)
    var spends: [Spend] = []

    init(name: String, plannedAmount: Decimal) {
        self.name = name
        self.plannedAmount = plannedAmount
        self.createdAt = .now
        self.isDefault = false
    }
}

extension Envelope {
    /// Сумма всех трат конверта. Меняется автоматически при вводе/правке/отмене трат.
    var spentAmount: Decimal {
        spends.reduce(0) { $0 + $1.amount }
    }

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
