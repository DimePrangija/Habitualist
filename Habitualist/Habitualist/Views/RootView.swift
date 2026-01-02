import SwiftUI
import SwiftData

struct RootView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var activeHabits: [Habit]
    
    var body: some View {
        if activeHabits.isEmpty {
            OnboardingView()
        } else {
            TodayView()
        }
    }
}
