import SwiftData
import SwiftUI

/// Правка или отмена уже внесённой траты.
struct SpendEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Envelope.createdAt, order: .forward)
    private var envelopes: [Envelope]

    @State private var viewModel: SpendFormViewModel
    @State private var isPickingCategory = false

    init(spend: Spend, context: ModelContext) {
        _viewModel = State(initialValue: SpendFormViewModel(mode: .edit(spend), context: context))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SpendInputPanel(
                    viewModel: viewModel,
                    submitSystemImage: "checkmark",
                    onCategoryTap: { isPickingCategory = true },
                    onSubmit: { if viewModel.save() { dismiss() } }
                )

                Button(role: .destructive) {
                    if viewModel.delete() { dismiss() }
                } label: {
                    Label("Отменить трату", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle("Изменить трату")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .sheet(isPresented: $isPickingCategory) {
                CategoryPickerView(
                    envelopes: envelopes,
                    selectedID: viewModel.selectedEnvelope?.persistentModelID,
                    onSelect: { viewModel.selectedEnvelope = $0 },
                    onMarkDefault: { viewModel.markAsDefault($0) }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
}
