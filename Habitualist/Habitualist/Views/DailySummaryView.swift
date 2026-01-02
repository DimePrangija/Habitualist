import SwiftUI
import SwiftData

struct DailySummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("writeDailySummaryToCalendar") private var writeDailySummaryToCalendar: Bool = false
    
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    
    @Query private var completions: [Completion]
    
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var isSaving = false
    
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
    
    private func generateSummaryNotes() -> String {
        var notes = "Date: \(todayKey)\n"
        notes += "Total Active Habits: \(habits.count)\n"
        notes += "Completed Today: \(completedTodayCount)\n\n"
        notes += "Habits:\n"
        
        for habit in habits {
            let completed = isCompletedToday(habit)
            let progress = weeklyProgress(habit)
            notes += "- \(habit.title): \(completed ? "Completed today" : "Not completed today"), \(progress.completed)/\(progress.target) this week\n"
        }
        
        return notes
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
                
                if writeDailySummaryToCalendar {
                    Section {
                        Button {
                            Task {
                                await saveToCalendar()
                            }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                                Text(isSaving ? "Saving..." : "Save to Calendar")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .disabled(isSaving)
                    }
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
            .alert("Calendar", isPresented: $showingSaveAlert) {
                Button("OK") {}
            } message: {
                Text(saveAlertMessage)
            }
        }
    }
    
    private func saveToCalendar() async {
        await MainActor.run {
            isSaving = true
        }
        
        do {
            let notes = generateSummaryNotes()
            try await CalendarEventService.shared.upsertDailySummaryEvent(
                date: Date(),
                title: "Habitualist Summary",
                notes: notes
            )
            
            await MainActor.run {
                isSaving = false
                saveAlertMessage = "Daily summary saved to Calendar successfully."
                showingSaveAlert = true
            }
        } catch {
            await MainActor.run {
                isSaving = false
                saveAlertMessage = error.localizedDescription
                showingSaveAlert = true
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
