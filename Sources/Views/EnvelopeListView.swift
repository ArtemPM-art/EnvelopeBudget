import SwiftData
import SwiftUI

struct EnvelopeListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Envelope.createdAt, order: .forward)
    private var envelopes: [Envelope]

    @Query private var activeEvents: [ShoppingEvent]

    @State private var route: EditorRoute?
    @State private var isEnteringSpend = false
    @State private var shoppingEvent: ShoppingEvent?

    private var hasActiveEvent: Bool { !activeEvents.isEmpty }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Конверты")
                .navigationBarTitleDisplayMode(.inline)
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
                        bottomActions
                    }
                }
        }
        .sheet(item: $route) { route in
            EnvelopeEditorView(mode: route.mode, context: context)
        }
    }

    private var bottomActions: some View {
        VStack(spacing: 10) {
            Button {
                startOrContinueShopping()
            } label: {
                Label(hasActiveEvent ? "Продолжить шопинг" : "Начать шопинг", systemImage: "cart")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.ebBlue)
            .fullScreenCover(item: $shoppingEvent) { event in
                ShoppingEventView(event: event, context: context)
            }

            Button {
                isEnteringSpend = true
            } label: {
                Label("Внести одну трату", systemImage: "plus")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.ebBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $isEnteringSpend) {
                SpendEntryView(context: context)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
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
                    Text("Заложено всего \(MoneyFormatter.string(from: totalPlanned))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        .padding(.bottom, 2)

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
        }
    }

    private func startOrContinueShopping() {
        if let active = activeEvents.first {
            shoppingEvent = active
            return
        }
        let event = ShoppingEvent()
        context.insert(event)
        try? context.save()
        shoppingEvent = event
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
