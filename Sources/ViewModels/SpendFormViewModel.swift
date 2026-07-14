import Foundation
import SwiftData

/// Логика ввода и правки одной траты.
/// Пользователь задаёт вручную только сумму и категорию (конверт).
/// Дата, тип операции и тип денег проставляются автоматически.
@Observable
final class SpendFormViewModel {
    enum Mode {
        case create
        case edit(Spend)
    }

    /// Строка вводимой суммы в целых рублях (без разделителей).
    var amountText: String = ""

    /// Выбранная категория (конверт) для текущей траты.
    var selectedEnvelope: Envelope?

    private(set) var saveError: String?

    /// Максимум цифр в сумме — защита от переполнения при случайном залипании.
    private let maxDigits = 9

    private let mode: Mode
    private let context: ModelContext

    init(mode: Mode, context: ModelContext) {
        self.mode = mode
        self.context = context

        switch mode {
        case .create:
            selectedEnvelope = Self.defaultEnvelope(in: context)
        case let .edit(spend):
            amountText = MoneyFormatter.editableText(from: spend.amount)
            selectedEnvelope = spend.envelope
        }
    }

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    /// Разобранная сумма. nil, если поле пустое или не число.
    var amount: Decimal? {
        MoneyFormatter.decimal(from: amountText)
    }

    /// Можно ли сохранить трату: есть положительная сумма и выбран конверт.
    var canSubmit: Bool {
        guard let amount, amount > 0 else { return false }
        return selectedEnvelope != nil
    }

    // MARK: - Ввод суммы с клавиатуры

    func appendDigit(_ digit: Int) {
        guard (0...9).contains(digit) else { return }
        guard amountText.count < maxDigits else { return }
        // Не даём копить ведущие нули: «0» + «5» = «5», а не «05».
        if amountText == "0" {
            amountText = ""
        }
        amountText.append(String(digit))
    }

    func deleteLastDigit() {
        guard !amountText.isEmpty else { return }
        amountText.removeLast()
    }

    // MARK: - Сохранение

    /// Внести новую трату. Категория сохраняется для следующей траты, сумма сбрасывается.
    @discardableResult
    func add() -> Bool {
        guard case .create = mode else { return false }
        guard let amount, amount > 0, let envelope = selectedEnvelope else { return false }

        context.insert(Spend(amount: amount, envelope: envelope))

        guard commit(failureMessage: "Не удалось внести трату.") else { return false }
        amountText = ""
        return true
    }

    /// Сохранить изменения существующей траты.
    @discardableResult
    func save() -> Bool {
        guard case let .edit(spend) = mode else { return false }
        guard let amount, amount > 0, let envelope = selectedEnvelope else { return false }

        spend.amount = amount
        spend.envelope = envelope
        return commit(failureMessage: "Не удалось сохранить трату.")
    }

    /// Отменить (удалить) существующую трату.
    @discardableResult
    func delete() -> Bool {
        guard case let .edit(spend) = mode else { return false }
        context.delete(spend)
        return commit(failureMessage: "Не удалось отменить трату.")
    }

    // MARK: - Категория по умолчанию

    /// Отметить конверт категорией по умолчанию для всех новых трат.
    func markAsDefault(_ envelope: Envelope) {
        let all = (try? context.fetch(FetchDescriptor<Envelope>())) ?? []
        for candidate in all {
            candidate.isDefault = (candidate.persistentModelID == envelope.persistentModelID)
        }
        try? context.save()
    }

    private func commit(failureMessage: String) -> Bool {
        do {
            try context.save()
            saveError = nil
            return true
        } catch {
            saveError = failureMessage
            return false
        }
    }

    /// Категория по умолчанию: помеченный конверт, иначе — самый первый.
    static func defaultEnvelope(in context: ModelContext) -> Envelope? {
        let descriptor = FetchDescriptor<Envelope>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        let all = (try? context.fetch(descriptor)) ?? []
        return all.first(where: \.isDefault) ?? all.first
    }
}
