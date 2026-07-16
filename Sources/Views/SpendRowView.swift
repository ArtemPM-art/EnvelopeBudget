import SwiftUI

/// Строка внесённой траты: сумма и рядом — категория (конверт).
/// Нераспределённая трата (без конверта) выделяется, чтобы её было легко вернуть в бюджет.
struct SpendRowView: View {
    let spend: Spend

    var body: some View {
        HStack(spacing: 12) {
            Text(MoneyFormatter.string(from: spend.amount))
                .font(.body.weight(.semibold))

            Spacer()

            if let name = spend.envelope?.name {
                categoryChip(text: name, tint: .secondary, filled: false)
            } else {
                categoryChip(text: "Не распределена", tint: .ebOrange, filled: true)
            }
        }
        .contentShape(Rectangle())
    }

    private func categoryChip(text: String, tint: Color, filled: Bool) -> some View {
        HStack(spacing: 4) {
            if filled {
                Image(systemName: "exclamationmark.circle")
                    .font(.caption)
            }
            Text(text)
                .lineLimit(1)
        }
        .font(.subheadline)
        .foregroundStyle(filled ? tint : Color.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(filled ? tint.opacity(0.15) : Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}
