import SwiftData
import SwiftUI

/// Активное событие «шопинг»: итог корзины и черновики конвертов «после оплаты».
/// Деньги в конвертах не трогаются, пока событие не оплачено.
struct ShoppingEventView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var viewModel: ShoppingEventViewModel
    @State private var isAddingSpend = false
    @State private var isConfirmingCancel = false
    @State private var checkout: CheckoutData?
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
            .sheet(isPresented: $isAddingSpend) {
                EventSpendEntryView(event: viewModel.event, context: context)
            }
            .sheet(item: $checkout) { data in
                EventCheckoutView(lines: data.lines, total: data.total) {
                    finishPay()
                }
            }
            .alert("Отменить событие «Шопинг»?", isPresented: $isConfirmingCancel) {
                Button("Отменить событие", role: .destructive) { finishCancel() }
                Button("Продолжить покупки", role: .cancel) {}
            } message: {
                Text("Все траты из корзины (\(MoneyFormatter.string(from: viewModel.cartTotal))) откатятся. Конверты останутся без изменений — деньги не списывались.")
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
                            draftCard(draft)
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
            Circle().fill(.green).frame(width: 9, height: 9)
            Text("СОБЫТИЕ ИДЁТ")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
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
                    .foregroundStyle(.tint)
                Text(draft.envelope.name)
                    .font(.headline)
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
                    .foregroundStyle(.orange)
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
                    .foregroundStyle(draft.isOverspent ? Color.red : Color.primary)
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
                isAddingSpend = true
            } label: {
                Label("Добавить трату в корзину", systemImage: "plus")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)

            HStack(spacing: 10) {
                Button(role: .destructive) {
                    isConfirmingCancel = true
                } label: {
                    Text("Отменить")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Button {
                    checkout = CheckoutData(lines: viewModel.draftLines(), total: viewModel.cartTotal)
                } label: {
                    Text("Оплатить · \(MoneyFormatter.string(from: viewModel.cartTotal))")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isEmpty)
            }
        }
        .padding(16)
        .background(.bar)
    }

    // MARK: - Finish

    private func finishPay() {
        checkout = nil
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

/// Снимок корзины для экрана оплаты.
private struct CheckoutData: Identifiable {
    let id = UUID()
    let lines: [DraftLine]
    let total: Decimal
}
