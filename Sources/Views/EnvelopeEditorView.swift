import SwiftData
import SwiftUI

struct EnvelopeEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EnvelopeEditorViewModel
    @State private var isConfirmingDelete = false

    init(mode: EnvelopeEditorViewModel.Mode, context: ModelContext) {
        _viewModel = State(initialValue: EnvelopeEditorViewModel(mode: mode, context: context))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Продукты", text: $viewModel.name)

                    if let nameError = viewModel.nameError {
                        errorLabel(nameError)
                    }
                }

                Section {
                    HStack {
                        TextField("0", text: $viewModel.amountText)
                            .keyboardType(.numberPad)
                        Text("₽")
                            .foregroundStyle(.secondary)
                    }

                    if let amountError = viewModel.amountError {
                        errorLabel(amountError)
                    }
                } header: {
                    Text("Сколько закладываем")
                } footer: {
                    Text("Это рамка на месяц. Потратить больше можно — приложение честно покажет минус.")
                }

                if let envelope = viewModel.editedEnvelope {
                    Section("Сейчас в конверте") {
                        LabeledContent("Потрачено", value: MoneyFormatter.string(from: envelope.spentAmount))
                        LabeledContent("Осталось", value: MoneyFormatter.string(from: envelope.remainingAmount))
                    }

                    Section {
                        Button(role: .destructive) {
                            isConfirmingDelete = true
                        } label: {
                            Label("Удалить конверт", systemImage: "trash")
                        }
                    }
                }

                if let saveError = viewModel.saveError {
                    Section {
                        errorLabel(saveError)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(
                "Удалить «\(viewModel.editedEnvelope?.name ?? "")»?",
                isPresented: $isConfirmingDelete
            ) {
                if viewModel.editedEnvelopeSpendCount > 0 {
                    Button("Оставить траты", role: .destructive) {
                        if viewModel.deleteKeepingSpends() { dismiss() }
                    }
                    Button("Удалить с тратами", role: .destructive) {
                        if viewModel.deleteWithSpends() { dismiss() }
                    }
                    Button("Отмена", role: .cancel) {}
                } else {
                    Button("Удалить конверт", role: .destructive) {
                        if viewModel.deleteWithSpends() { dismiss() }
                    }
                    Button("Отмена", role: .cancel) {}
                }
            } message: {
                if viewModel.editedEnvelopeSpendCount > 0 {
                    Text(
                        """
                        Трат в этом конверте: \(viewModel.editedEnvelopeSpendCount). Выберите, что с ними сделать.
                        «Оставить траты» — конверт удалится, а траты станут нераспределёнными: перестанут влиять на бюджет, потом их можно вернуть в другой конверт.
                        «Удалить с тратами» — конверт и его траты удалятся безвозвратно.
                        """
                    )
                } else {
                    Text("Конверт исчезнет из списка. Вернуть его будет нельзя.")
                }
            }
        }
    }

    private func errorLabel(_ text: String) -> some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.footnote)
            .foregroundStyle(.red)
    }
}
