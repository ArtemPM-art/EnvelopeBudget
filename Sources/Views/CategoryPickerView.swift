import SwiftData
import SwiftUI

/// Выпадающий список категорий (конвертов) в момент ввода траты.
/// Тап по строке — выбрать категорию для текущей траты и закрыть список.
/// Тап по галочке слева — назначить категорию по умолчанию для всех новых трат.
struct CategoryPickerView: View {
    let envelopes: [Envelope]
    let selectedID: PersistentIdentifier?
    let onSelect: (Envelope) -> Void
    let onMarkDefault: (Envelope) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(envelopes) { envelope in
                        row(for: envelope)
                    }
                } footer: {
                    Text("Галочка слева — категория по умолчанию для новых трат.")
                }
            }
            .navigationTitle("Категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private func row(for envelope: Envelope) -> some View {
        HStack(spacing: 12) {
            Button {
                onMarkDefault(envelope)
            } label: {
                Image(systemName: envelope.isDefault ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(envelope.isDefault ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(envelope.isDefault ? "Категория по умолчанию" : "Сделать категорией по умолчанию")

            Button {
                onSelect(envelope)
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(envelope.name)
                            .foregroundStyle(.primary)
                        Text("осталось \(MoneyFormatter.string(from: envelope.remainingAmount))")
                            .font(.caption)
                            .foregroundStyle(envelope.isOverspent ? Color.red : Color.secondary)
                    }
                    Spacer()
                    if envelope.persistentModelID == selectedID {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
