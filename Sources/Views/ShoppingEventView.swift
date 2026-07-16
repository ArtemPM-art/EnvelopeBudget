import SwiftData
import SwiftUI

/// Активное событие «шопинг»: итог корзины и черновики конвертов «после оплаты».
/// Деньги в конвертах не трогаются, пока событие не оплачено.
struct ShoppingEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var viewModel: ShoppingEventViewModel
    @State private var sheet: EventSheet?
    @State private var isConfirmingCancel = false
    /// Пока true — событие закрывается: не читаем удаляемую модель во время анимации.
    @State private var isFinishing = false

    init(event: ShoppingEvent, context: ModelContext) {
        _viewModel = State(initialValue: ShoppingEventViewModel(event: event, context: context))
    }

    var body: some View {
        NavigationStack {
            Group {
                if isFinishing {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                } else {
                    activeContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { eventBadge }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Свернуть") { dismiss() }
                }
            }
            .sheet(item: $sheet) { sheet in
                sheetContent(sheet)
            }
            .alert("Отменить событие «Шопинг»?", isPresented: $isConfirmingCancel) {
                Button("Отменить событие", role: .destructive) { finishCancel() }
                Button("Продолжить покупки", role: .cancel) {}
            } message: {
                Text("Все траты из корзины (\(MoneyFormatter.string(from: viewModel.cartTotal))) откатятся. Конверты останутся без изменений — деньги не списывались.")
            }
        }
    }

    // MARK: - Sheets

    @ViewBuilder
    private func sheetContent(_ sheet: EventSheet) -> some View {
        switch sheet {
        case .addSpend:
            EventSpendEntryView(event: viewModel.event, context: context)
        case let .envelopeSpends(envelope):
            EventEnvelopeSpendsView(envelope: envelope, event: viewModel.event, context: context)
        case let .checkout(lines, total):
            EventCheckoutView(lines: lines, total: total) {
                finishPay()
            }
        }
    }

    // MARK: - Content

    private var activeContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Шопинг")
                        .font(.title.bold())

                    summaryCard

                    Text("Черновик конвертов")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    if viewModel.drafts.isEmpty {
                        emptyCart
                    } else {
                        ForEach(viewModel.drafts) { draft in
                            Button {
                                sheet = .envelopeSpends(draft.envelope)
                            } label: {
                                draftCard(draft)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            bottomActions
        }
    }

    private var eventBadge: some View {
        HStack(spacing: 8) {
            Circle().fill(Color.ebGreen).frame(width: 9, height: 9)
            Text("СОБЫТИЕ ИДЁТ")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ebGreen)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("В корзине сейчас")
                .font(.footnote)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline) {
                Text(MoneyFormatter.string(from: viewModel.cartTotal))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Text("\(viewModel.itemCount) \(Pluralize.positions(viewModel.itemCount)) · не оплачено")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func draftCard(_ draft: EnvelopeDraft) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 9) {
                Image(systemName: "cart")
                    .foregroundStyle(Color.ebBlue)
                Text(draft.envelope.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("ЧЕРНОВИК")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                Spacer()
                Text("−\(MoneyFormatter.string(from: draft.spend))")
                    .font(.headline)
                    .foregroundStyle(Color.ebOrange)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Divider()

            HStack {
                Text("после оплаты останется")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(MoneyFormatter.string(from: draft.wasRemaining))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .strikethrough()
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(MoneyFormatter.string(from: draft.afterRemaining))
                    .font(.headline)
                    .foregroundStyle(draft.isOverspent ? Color.ebRed : Color.primary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var emptyCart: some View {
        Text("Корзина пуста — добавьте первую трату.")
            .font(.callout)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
    }

    private var bottomActions: some View {
        VStack(spacing: 10) {
            Button {
                sheet = .addSpend
            } label: {
                Label("Добавить трату в корзину", systemImage: "plus")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.ebBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button {
                    isConfirmingCancel = true
                } label: {
                    Text("Отменить")
                        .font(.headline)
                        .foregroundStyle(Color.ebRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    sheet = .checkout(lines: viewModel.draftLines(), total: viewModel.cartTotal)
                } label: {
                    Text("Оплатить · \(MoneyFormatter.string(from: viewModel.cartTotal))")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.isEmpty ? Color.ebGreen.opacity(0.4) : Color.ebGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isEmpty)
            }
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Finish

    private func finishPay() {
        sheet = nil
        isFinishing = true
        viewModel.payAndClose()
        dismiss()
    }

    private func finishCancel() {
        isFinishing = true
        viewModel.cancelEvent()
        dismiss()
    }
}

/// Что показываем поверх экрана события. Один источник — чтобы презентации не конфликтовали.
private enum EventSheet: Identifiable {
    case addSpend
    case envelopeSpends(Envelope)
    case checkout(lines: [DraftLine], total: Decimal)

    var id: String {
        switch self {
        case .addSpend:
            return "add"
        case let .envelopeSpends(envelope):
            return "env-\(envelope.persistentModelID)"
        case .checkout:
            return "checkout"
        }
    }
}
