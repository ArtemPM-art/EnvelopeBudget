import Foundation
import SwiftData

@Observable
final class EnvelopeEditorViewModel {
    enum Mode {
        case create
        case edit(Envelope)
    }

    var name: String = ""
    var amountText: String = ""

    private(set) var nameError: String?
    private(set) var amountError: String?
    private(set) var saveError: String?

    private let mode: Mode
    private let context: ModelContext

    init(mode: Mode, context: ModelContext) {
        self.mode = mode
        self.context = context

        if case let .edit(envelope) = mode {
            name = envelope.name
            amountText = MoneyFormatter.editableText(from: envelope.plannedAmount)
        }
    }

    var editedEnvelope: Envelope? {
        if case let .edit(envelope) = mode { return envelope }
        return nil
    }

    /// Сколько трат уже привязано к редактируемому конверту.
    var editedEnvelopeSpendCount: Int {
        editedEnvelope?.spends.count ?? 0
    }

    var title: String {
        editedEnvelope?.name ?? "Новый конверт"
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && MoneyFormatter.decimal(from: amountText) != nil
    }

    /// true — сохранилось, экран можно закрывать.
    func save() -> Bool {
        nameError = nil
        amountError = nil
        saveError = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            nameError = "Впишите название конверта."
            return false
        }

        guard let amount = MoneyFormatter.decimal(from: amountText) else {
            amountError = "Впишите сумму числом."
            return false
        }

        guard isNameFree(trimmedName) else {
            nameError = "Конверт «\(trimmedName)» уже есть. Выберите другое название."
            return false
        }

        switch mode {
        case .create:
            context.insert(Envelope(name: trimmedName, plannedAmount: amount))
        case let .edit(envelope):
            envelope.name = trimmedName
            envelope.plannedAmount = amount
        }

        return commit(failureMessage: "Не удалось сохранить конверт.")
    }

    /// Удалить конверт вместе со всеми его тратами (каскадное удаление).
    func deleteWithSpends() -> Bool {
        guard let envelope = editedEnvelope else { return false }
        context.delete(envelope)
        return commit(failureMessage: "Не удалось удалить конверт.")
    }

    /// Удалить конверт, но сохранить траты: они станут нераспределёнными
    /// (envelope = nil), перестанут влиять на бюджет и их можно вернуть в другой конверт.
    func deleteKeepingSpends() -> Bool {
        guard let envelope = editedEnvelope else { return false }
        // Снимаем траты с конверта до его удаления, иначе каскад унесёт их с собой.
        let attachedSpends = envelope.spends
        for spend in attachedSpends {
            spend.envelope = nil
        }
        context.delete(envelope)
        return commit(failureMessage: "Не удалось удалить конверт.")
    }

    private func commit(failureMessage: String) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            saveError = failureMessage
            return false
        }
    }

    /// Сравнение без учёта регистра: «Продукты» и «продукты» — один конверт.
    private func isNameFree(_ candidate: String) -> Bool {
        guard let existing = try? context.fetch(FetchDescriptor<Envelope>()) else {
            return true
        }

        let editedID = editedEnvelope?.persistentModelID

        return !existing.contains { envelope in
            guard envelope.persistentModelID != editedID else { return false }
            return envelope.name.compare(candidate, options: .caseInsensitive) == .orderedSame
        }
    }
}
