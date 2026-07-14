import SwiftUI

/// Цифровая клавиатура ввода суммы.
/// Показывается на экране постоянно — системная клавиатура не нужна,
/// поэтому ввод суммы укладывается в один «тап» по продуктовому счёту.
struct AmountKeypad: View {
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onSubmit: () -> Void
    var submitEnabled: Bool
    var submitSystemImage: String

    private enum Key: Hashable {
        case digit(Int)
        case delete
        case submit
    }

    private let keys: [Key] = [
        .digit(1), .digit(2), .digit(3),
        .digit(4), .digit(5), .digit(6),
        .digit(7), .digit(8), .digit(9),
        .delete, .digit(0), .submit
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(keys, id: \.self) { key in
                keyButton(for: key)
            }
        }
    }

    @ViewBuilder
    private func keyButton(for key: Key) -> some View {
        switch key {
        case let .digit(value):
            Button {
                onDigit(value)
            } label: {
                Text(String(value))
                    .font(.title2.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(KeyButtonStyle(kind: .neutral))

        case .delete:
            Button {
                onDelete()
            } label: {
                Image(systemName: "delete.left")
                    .font(.title2)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(KeyButtonStyle(kind: .neutral))

        case .submit:
            Button {
                onSubmit()
            } label: {
                Image(systemName: submitSystemImage)
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(KeyButtonStyle(kind: .accent))
            .disabled(!submitEnabled)
        }
    }
}

private struct KeyButtonStyle: ButtonStyle {
    enum Kind {
        case neutral
        case accent
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        KeyButtonBody(kind: kind, configuration: configuration)
    }

    // Отдельный View нужен, чтобы читать среду (isEnabled): сам ButtonStyle её не видит.
    private struct KeyButtonBody: View {
        let kind: Kind
        let configuration: ButtonStyleConfiguration
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .foregroundStyle(foreground)
                .background(background(pressed: configuration.isPressed))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .opacity(isEnabled ? 1 : 0.4)
        }

        private var foreground: Color {
            switch kind {
            case .neutral:
                return .primary
            case .accent:
                return .white
            }
        }

        private func background(pressed: Bool) -> Color {
            switch kind {
            case .neutral:
                return Color(.secondarySystemBackground).opacity(pressed ? 0.6 : 1)
            case .accent:
                return Color.accentColor.opacity(pressed ? 0.7 : 1)
            }
        }
    }
}
