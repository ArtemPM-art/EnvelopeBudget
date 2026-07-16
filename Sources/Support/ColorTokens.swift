import SwiftUI

/// Дизайн-токены цветов из макета. Тёмная тема, значения фиксированы.
extension Color {
    /// Акцент/действие — #0a84ff
    static let ebBlue = Color(red: Double(0x0A) / 255, green: Double(0x84) / 255, blue: Double(0xFF) / 255)
    /// Событие/оплата — #34c759
    static let ebGreen = Color(red: Double(0x34) / 255, green: Double(0xC7) / 255, blue: Double(0x59) / 255)
    /// Черновик траты/предупреждение — #ff9f0a
    static let ebOrange = Color(red: Double(0xFF) / 255, green: Double(0x9F) / 255, blue: Double(0x0A) / 255)
    /// Отмена/перерасход — #ff453a
    static let ebRed = Color(red: Double(0xFF) / 255, green: Double(0x45) / 255, blue: Double(0x3A) / 255)
}
