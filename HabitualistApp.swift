import SwiftUI
import SwiftData

@main
struct HabitualistApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearanceMode.colorScheme)
        }
        .modelContainer(for: [Habit.self, Completion.self])
    }
}

extension AppearanceMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

