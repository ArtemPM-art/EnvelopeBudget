import SwiftUI

/// Экран оплаты корзины: что и сколько спишется из конвертов, честное предупреждение
/// о минусе и кнопка провести оплату. Работает по снимку (DraftLine), не по живой модели.
struct EventCheckoutView: View {
    @Environment(\.dismiss) private var dismiss

    let lines: [DraftLine]
    let total: Decimal
    let onConfirm: () -> Void

    private var overspent: [DraftLine] {
        lines.filter(\.isOverspent)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Оплатить корзину")
                            .font(.title.bold())
                        Text("После оплаты \(MoneyFormatter.string(from: total)) спишутся из конвертов. Отменить будет нельзя.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Text("Спишется из конвертов")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        ForEach(lines) { line in
                            checkoutRow(line)
                            Divider()
                        }
                        HStack {
                            Text("Итого").font(.headline)
                            Spacer()
                            Text(MoneyFormatter.string(from: total))
                                .font(.title3.bold())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    if !overspent.isEmpty {
                        overspendWarning
                    }
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    onConfirm()
                } label: {
                    Text("Провести оплату · \(MoneyFormatter.string(from: total))")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.ebGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(.bar)
            }
            .navigationTitle("Закрытие события")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Назад") { dismiss() }
                }
            }
        }
    }

    private func checkoutRow(_ line: DraftLine) -> some View {
        HStack {
            Image(systemName: "cart")
                .foregroundStyle(.secondary)
            Text(line.name)
            Spacer()
            Text("−\(MoneyFormatter.string(from: line.spend))")
                .font(.body.weight(.semibold))
            Text("→ \(MoneyFormatter.string(from: line.after))")
                .font(.footnote)
                .foregroundStyle(line.isOverspent ? Color.ebRed : Color.secondary)
                .frame(minWidth: 78, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var overspendWarning: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.ebOrange)
            Text(overspendMessage)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ebOrange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var overspendMessage: String {
        if overspent.count == 1, let line = overspent.first {
            let minus = MoneyFormatter.string(from: -line.after)
            return "Конверт «\(line.name)» уйдёт в минус на \(minus). Приложение честно покажет это."
        }
        let names = overspent.map { "«\($0.name)»" }.joined(separator: ", ")
        return "Конверты \(names) уйдут в минус. Приложение честно покажет это."
    }
}
