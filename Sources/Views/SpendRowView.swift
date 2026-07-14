import SwiftUI

/// Строка внесённой траты: сумма и рядом — категория (конверт).
struct SpendRowView: View {
    let spend: Spend

    var body: some View {
        HStack(spacing: 12) {
            Text(MoneyFormatter.string(from: spend.amount))
                .font(.body.weight(.semibold))

            Spacer()

            Text(spend.envelope?.name ?? "Без категории")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
        }
        .contentShape(Rectangle())
    }
}
