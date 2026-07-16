import SwiftData
import SwiftUI

/// Ввод траты внутри события: сумма и конверт складываются в корзину (черновик).
struct EventSpendEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Envelope.createdAt, order: .forward)
    private var envelopes: [Envelope]

    @State private var viewModel: SpendFormViewModel
    @State private var isPickingCategory = false

    init(event: ShoppingEvent, context: ModelContext) {
        _viewModel = State(initialValue: SpendFormViewModel(mode: .create, context: context, event: event))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SpendInputPanel(
                    viewModel: viewModel,
                    submitSystemImage: "checkmark",
                    onCategoryTap: { isPickingCategory = true },
                    onSubmit: { if viewModel.add() { dismiss() } }
                )
                Spacer(minLength: 0)
            }
            .padding(16)
            .navigationTitle("В корзину «Шопинг»")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
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
