import Foundation

enum Pluralize {
    /// Русское склонение: 1 позиция, 2 позиции, 5 позиций.
    static func positions(_ count: Int) -> String {
        word(count, one: "позиция", few: "позиции", many: "позиций")
    }

    static func word(_ count: Int, one: String, few: String, many: String) -> String {
        let n = abs(count) % 100
        let n10 = n % 10
        if n >= 11 && n <= 14 { return many }
        if n10 == 1 { return one }
        if n10 >= 2 && n10 <= 4 { return few }
        return many
    }
}
