import SwiftData
import SwiftUI

@main
struct EnvelopeBudgetApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Envelope.self)
        } catch {
            // Без хранилища приложение бессмысленно: конверты негде держать.
            fatalError("Не удалось создать хранилище конвертов: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            EnvelopeListView()
        }
        .modelContainer(container)
    }
}
