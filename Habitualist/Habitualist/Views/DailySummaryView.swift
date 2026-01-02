import SwiftUI
import SwiftData

struct DailySummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    
    @Query private var completions: [Completion]
    
    private var todayKey: String {
        DayKeyService.todayKey()
    }
    
    private var completedTodayCount: Int {
        let todayCompletions = completions.filter { $0.dateKey == todayKey }
        let uniqueHabitIds = Set(todayCompletions.map { $0.habitId })
        return uniqueHabitIds.count
    }
    
    private func isCompletedToday(_ habit: Habit) -> Bool {
        completions.contains { $0.habitId == habit.id && $0.dateKey == todayKey }
    }
    
    private func weeklyProgress(_ habit: Habit) -> (completed: Int, target: Int) {
        let completed = WeeklyProgressService.completionsThisWeek(habitId: habit.id, for: Date(), in: modelContext)
        return (completed, habit.targetDaysPerWeek)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(formatDate())
                        .font(.headline)
                } header: {
                    Text("Date")
                }
                
                Section {
                    HStack {
                        Text("Total Active Habits")
                        Spacer()
                        Text("\(habits.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completed Today")
                        Spacer()
                        Text("\(completedTodayCount)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Summary")
                }
                
                Section {
                    ForEach(habits) { habit in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(habit.title)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text(isCompletedToday(habit) ? "Completed today" : "Not completed today")
                                    .font(.caption)
                                    .foregroundColor(isCompletedToday(habit) ? .green : .secondary)
                                
                                Spacer()
                                
                                let progress = weeklyProgress(habit)
                                Text("\(progress.completed)/\(progress.target) this week")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Habits")
                }
            }
            .navigationTitle("Daily Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}
