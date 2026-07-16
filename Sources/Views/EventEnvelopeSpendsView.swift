import SwiftData
import SwiftUI

/// Все траты одного конверта в рамках события — раздельно.
/// Каждую можно изменить или отменить, не трогая остальную корзину.
struct EventEnvelopeSpendsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let envelope: Envelope
    let event: ShoppingEvent

    @State private var editingSpend: Spend?

    private var spends: [Spend] {
        event.spends
            .filter { $0.envelope?.persistentModelID == envelope.persistentModelID }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var total: Decimal {
        spends.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            Group {
                if spends.isEmpty {
                    ContentUnavailableView {
                        Label("В этом конверте пусто", systemImage: "cart")
                    } description: {
                        Text("Все траты по конверту отменены.")
                    }
                } else {
                    List {
                        Section {
                            ForEach(spends) { spend in
                                Button {
                                    editingSpend = spend
                                } label: {
                                    HStack {
                                        Text(MoneyFormatter.string(from: spend.amount))
                                            .font(.body.weight(.semibold))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .contentShape(Rectangle())
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
                        } header: {
                            Text("Траты в событии")
                        } footer: {
                            HStack {
                                Text("Всего по конверту")
                                Spacer()
                                Text(MoneyFormatter.string(from: total))
                                    .foregroundStyle(.ebOrange)
                            }
                            .font(.subheadline.weight(.medium))
                        }
                    }
                }
            }
            .navigationTitle(envelope.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
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
