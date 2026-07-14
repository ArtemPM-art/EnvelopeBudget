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
            .confirmationDialog(
                "Удалить «\(viewModel.editedEnvelope?.name ?? "")»?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Удалить конверт", role: .destructive) {
                    if viewModel.delete() { dismiss() }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Конверт исчезнет из списка. Вернуть его будет нельзя.")
            }
        }
    }

    private func errorLabel(_ text: String) -> some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.footnote)
            .foregroundStyle(.red)
    }
}
