import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Пайплайн работает")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Сборка 0.1")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
