import Foundation
import SwiftData

struct WeeklyProgressService {
    static func completionsThisWeek(habitId: UUID, for date: Date, in modelContext: ModelContext) -> Int {
        let weekStart = DayKeyService.weekStartDate(for: date)
        let weekEnd = Calendar(identifier: .iso8601).date(byAdding: .day, value: 6, to: weekStart) ?? date
        
        let startKey = DayKeyService.dateKey(for: weekStart)
        let endKey = DayKeyService.dateKey(for: weekEnd)
        
        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate<Completion> { completion in
                completion.habitId == habitId &&
                completion.dateKey >= startKey &&
                completion.dateKey <= endKey
            }
        )
        
        do {
            let completions = try modelContext.fetch(descriptor)
            let uniqueDateKeys = Set(completions.map { $0.dateKey })
            return uniqueDateKeys.count
        } catch {
            return 0
        }
    }
    
    static func isWeekCompleted(_ habit: Habit, for date: Date, in modelContext: ModelContext) -> Bool {
        let count = completionsThisWeek(habitId: habit.id, for: date, in: modelContext)
        return count >= habit.targetDaysPerWeek
    }
}
