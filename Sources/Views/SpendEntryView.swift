import SwiftData
import SwiftUI

/// Экран «Покупки» — быстрый ввод трат прямо в магазине.
/// Ввёл сумму, при необходимости сменил категорию, нажал галочку — трата в бюджете.
struct SpendEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query(sort: \Envelope.createdAt, order: .forward)
    private var envelopes: [Envelope]

    @Query(sort: \Spend.createdAt, order: .reverse)
    private var spends: [Spend]

    @State private var viewModel: SpendFormViewModel
    @State private var isPickingCategory = false
    @State private var editingSpend: Spend?

    init(context: ModelContext) {
        _viewModel = State(initialValue: SpendFormViewModel(mode: .create, context: context))
    }

    var body: some View {
        NavigationStack {
            Group {
                if envelopes.isEmpty {
                    ContentUnavailableView {
                        Label("Сначала создайте конверт", systemImage: "tray")
                    } description: {
                        Text("Траты вносятся в категорию — а категории берутся из ваших конвертов.")
                    }
                } else {
                    VStack(spacing: 0) {
                        spendsList
                        Divider()
                        inputPanel
                    }
                }
            }
            .navigationTitle("Покупки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }

    private var inputPanel: some View {
        SpendInputPanel(
            viewModel: viewModel,
            submitSystemImage: "checkmark",
            onCategoryTap: { isPickingCategory = true },
            onSubmit: { viewModel.add() }
        )
        .padding(16)
        .background(Color(.systemGroupedBackground))
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

    @ViewBuilder
    private var spendsList: some View {
        if spends.isEmpty {
            ContentUnavailableView {
                Label("Пока ничего не внесено", systemImage: "cart")
            } description: {
                Text("Введите сумму и нажмите галочку.")
            }
            .frame(maxHeight: .infinity)
        } else {
            List {
                Section("Внесённые траты") {
                    ForEach(spends) { spend in
                        Button {
                            editingSpend = spend
                        } label: {
                            SpendRowView(spend: spend)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(spend)
                            } label: {
                                Label("Отменить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .sheet(item: $editingSpend) { spend in
                SpendEditorView(spend: spend, context: context)
            }
        }
    }

    private func delete(_ spend: Spend) {
        context.delete(spend)
        try? context.save()
    }
}
