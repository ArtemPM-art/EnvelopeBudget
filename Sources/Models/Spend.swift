import Foundation
import SwiftData

/// Тип операции. Пока только расход — приложение учитывает траты.
/// Значение задаётся автоматически, пользователь его не выбирает.
enum SpendOperationType: String, Codable, CaseIterable {
    case expense
}

/// Тип денег. По умолчанию «регулярный доход» — обычные деньги месяца.
/// Значение задаётся автоматически, пользователь его не выбирает.
enum SpendMoneyType: String, Codable, CaseIterable {
    case regularIncome
}

@Model
final class Spend {
    var amount: Decimal
    var date: Date
    var operationType: SpendOperationType
    var moneyType: SpendMoneyType
    var createdAt: Date

    /// Конверт (категория), к которому привязана трата.
    /// Опционален на уровне схемы, но при вводе всегда заполнен.
    var envelope: Envelope?

    init(
        amount: Decimal,
        envelope: Envelope?,
        date: Date = .now,
        operationType: SpendOperationType = .expense,
        moneyType: SpendMoneyType = .regularIncome
    ) {
        self.amount = amount
        self.envelope = envelope
        self.date = date
        self.operationType = operationType
        self.moneyType = moneyType
        self.createdAt = .now
    }
}
