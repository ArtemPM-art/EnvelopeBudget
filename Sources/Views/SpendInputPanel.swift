import SwiftUI

/// Нижняя панель ввода: сумма, кнопка выбора категории и клавиатура.
/// Переиспользуется на экране покупок и в окне правки траты.
struct SpendInputPanel: View {
    @Bindable var viewModel: SpendFormViewModel
    let submitSystemImage: String
    let onCategoryTap: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(MoneyFormatter.string(from: viewModel.amount ?? 0))
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(viewModel.amount == nil ? Color.secondary : Color.primary)
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Button(action: onCategoryTap) {
                HStack {
                    Image(systemName: "tray.full")
                    Text(viewModel.selectedEnvelope?.name ?? "Выберите категорию")
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            AmountKeypad(
                onDigit: { viewModel.appendDigit($0) },
                onDelete: { viewModel.deleteLastDigit() },
                onSubmit: onSubmit,
                submitEnabled: viewModel.canSubmit,
                submitSystemImage: submitSystemImage
            )
        }
    }
}
