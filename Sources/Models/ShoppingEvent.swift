import Foundation
import SwiftData

/// Событие «поход в магазин» — контейнер черновых трат.
/// Пока событие открыто, его траты не списываются с конвертов (это черновик).
/// При отмене траты откатываются; при оплате — становятся фактическими.
@Model
final class ShoppingEvent {
    var startedAt: Date

    /// Черновые траты корзины. Отмена/удаление события уносит их с собой (откат).
    @Relationship(deleteRule: .cascade, inverse: \Spend.event)
    var spends: [Spend] = []

    init() {
        self.startedAt = .now
    }
}
