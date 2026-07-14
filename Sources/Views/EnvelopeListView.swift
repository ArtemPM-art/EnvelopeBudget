import SwiftData
import SwiftUI

struct EnvelopeListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Envelope.createdAt, order: .forward)
    private var envelopes: [Envelope]

    @State private var route: EditorRoute?
    @State private var isEnteringSpend = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Конверты")
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            route = .create
                        } label: {
                            Label("Новый конверт", systemImage: "plus")
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if !envelopes.isEmpty {
                        Button {
                            isEnteringSpend = true
                        } label: {
                            Label("Внести трату", systemImage: "cart.badge.plus")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
        }
        .sheet(item: $route) { route in
            EnvelopeEditorView(mode: route.mode, context: context)
        }
        .fullScreenCover(isPresented: $isEnteringSpend) {
            SpendEntryView(context: context)
        }
    }

    @ViewBuilder
    private var content: some View {
        if envelopes.isEmpty {
            ContentUnavailableView {
                Label("Пока ни одного конверта", systemImage: "tray")
            } description: {
                Text("Создайте конверт и задайте, сколько готовы на него тратить.")
            } actions: {
                Button("Создать конверт") { route = .create }
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(envelopes) { envelope in
                        Button {
                            route = .edit(envelope)
                        } label: {
                            EnvelopeCardView(envelope: envelope)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("Заложено всего \(MoneyFormatter.string(from: totalPlanned))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .background(Color(.systemGroupedBackground))
            }
        }
    }

    private var totalPlanned: Decimal {
        envelopes.reduce(0) { $0 + $1.plannedAmount }
    }
}

private enum EditorRoute: Identifiable {
    case create
    case edit(Envelope)

    var id: String {
        switch self {
        case .create:
            return "create"
        case let .edit(envelope):
            return String(describing: envelope.persistentModelID)
        }
    }

    var mode: EnvelopeEditorViewModel.Mode {
        switch self {
        case .create:
            return .create
        case let .edit(envelope):
            return .edit(envelope)
        }
    }
}
