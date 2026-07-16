import Foundation
import SwiftData

/// Черновик одного конверта в рамках события: сколько уйдёт и что останется.
struct EnvelopeDraft: Identifiable {
    let envelope: Envelope
    let spend: Decimal

    var id: PersistentIdentifier { envelope.persistentModelID }

    /// Остаток конверта сейчас (черновые траты ещё не списаны).
    var wasRemaining: Decimal { envelope.remainingAmount }

    /// Остаток, если корзину оплатить.
    var afterRemaining: Decimal { envelope.remainingAmount - spend }

    var isOverspent: Bool { afterRemaining < 0 }
}

/// Плоский снимок черновика для экрана оплаты — не держит ссылку на модель,
/// поэтому безопасен при закрытии экрана, когда событие уже удалено.
struct DraftLine: Identifiable {
    let id = UUID()
    let name: String
    let spend: Decimal
    let after: Decimal
    var isOverspent: Bool { after < 0 }
}

@Observable
final class ShoppingEventViewModel {
    let event: ShoppingEvent
    private let context: ModelContext

    init(event: ShoppingEvent, context: ModelContext) {
        self.event = event
        self.context = context
    }

    /// Сумма всей корзины события.
    var cartTotal: Decimal {
        event.spends.reduce(0) { $0 + $1.amount }
    }

    var itemCount: Int {
        event.spends.count
    }

    var isEmpty: Bool {
        event.spends.isEmpty
    }

    /// Черновики конвертов: траты одного конверта суммируются в одну строку.
    var drafts: [EnvelopeDraft] {
        var totals: [PersistentIdentifier: (envelope: Envelope, sum: Decimal)] = [:]
        for spend in event.spends {
            guard let envelope = spend.envelope else { continue }
            let key = envelope.persistentModelID
            let running = totals[key]?.sum ?? 0
            totals[key] = (envelope, running + spend.amount)
        }
        return totals.values
            .map { EnvelopeDraft(envelope: $0.envelope, spend: $0.sum) }
            .sorted { $0.envelope.createdAt < $1.envelope.createdAt }
    }

    /// Снимок черновиков для экрана оплаты (без ссылок на модели).
    func draftLines() -> [DraftLine] {
        drafts.map { DraftLine(name: $0.envelope.name, spend: $0.spend, after: $0.afterRemaining) }
    }

    /// Отменить событие: все черновые траты откатываются, конверты не тронуты.
    func cancelEvent() {
        context.delete(event) // каскад удаляет черновые траты корзины
        try? context.save()
    }

    /// Оплатить и закрыть: черновые траты становятся фактическими и списываются с конвертов.
    func payAndClose() {
        let snapshot = event.spends
        for spend in snapshot {
            spend.event = nil // трата выходит из корзины и начинает влиять на бюджет
        }
        context.delete(event) // корзина пуста — каскаду нечего удалять
        try? context.save()
    }
}
