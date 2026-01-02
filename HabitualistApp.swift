import SwiftUI
import SwiftData

@main
struct HabitualistApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(for: [Habit.self, Completion.self])
    }
}

