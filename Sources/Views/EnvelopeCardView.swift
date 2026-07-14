import SwiftUI

struct EnvelopeCardView: View {
    let envelope: Envelope

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(envelope.name)
                    .font(.headline)

                Spacer()

                Text(MoneyFormatter.string(from: envelope.remainingAmount))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(envelope.isOverspent ? Color.red : Color.primary)
            }

            SpendingBar(fraction: envelope.spentFraction, isOverspent: envelope.isOverspent)

            HStack {
                Text("заложено \(MoneyFormatter.string(from: envelope.plannedAmount))")
                Spacer()
                Text("потрачено \(MoneyFormatter.string(from: envelope.spentAmount))")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(envelope.isOverspent ? Color.red.opacity(0.6) : Color.clear)
        }
    }
}

private struct SpendingBar: View {
    let fraction: Double
    let isOverspent: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))

                Capsule()
                    .fill(isOverspent ? Color.red : Color.green)
                    .frame(width: geometry.size.width * fraction)
            }
        }
        .frame(height: 6)
    }
}
