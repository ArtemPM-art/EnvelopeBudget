import SwiftData
import SwiftUI

@main
struct EnvelopeBudgetApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Envelope.self, Spend.self)
        } catch {
            // Без хранилища приложение бессмысленно: конверты и траты негде держать.
            fatalError("Не удалось создать хранилище: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            EnvelopeListView()
        }
        .modelContainer(container)
    }
}
