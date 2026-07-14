import Foundation

enum MoneyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "\u{00A0}"
        return formatter
    }()

    static func string(from amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let digits = formatter.string(from: number) ?? "0"
        return "\(digits)\u{00A0}₽"
    }

    /// Суммы храним в целых рублях: копейки продукту не нужны.
    static func decimal(from text: String) -> Decimal? {
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return Decimal(string: digits)
    }

    static func editableText(from amount: Decimal) -> String {
        NSDecimalNumber(decimal: amount).stringValue
    }
}
