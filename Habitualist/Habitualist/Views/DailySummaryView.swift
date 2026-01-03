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
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            Text(formatDate())
                                .font(ThemeFonts.habitTitle())
                                .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cardStyle(
                                    backgroundColor: ThemeColors.cardDark,
                                    borderColor: ThemeColors.borderDark,
                                    isChecked: false
                                )
                        }
                        
                        // Summary card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Summary")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total Active Habits")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    
                                    Spacer()
                                    
                                    Text("\(habits.count)")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                }
                                
                                Rectangle()
                                    .fill(ThemeColors.divider)
                                    .frame(height: 1)
                                
                                HStack {
                                    Text("Completed Today")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    
                                    Spacer()
                                    
                                    Text("\(completedTodayCount)")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                }
                            }
                            .padding(16)
                            .cardStyle(
                                backgroundColor: ThemeColors.cardDark,
                                borderColor: ThemeColors.borderDark,
                                isChecked: false
                            )
                        }
                        
                        // Save to Calendar button (if enabled)
                        if writeDailySummaryToCalendar {
                            Button {
                                Task {
                                    await saveToCalendar()
                                }
                            } label: {
                                HStack {
                                    if isSaving {
                                        ProgressView()
                                            .tint(ThemeColors.textPrimaryOnBlue)
                                            .scaleEffect(0.8)
                                    }
                                    Text(isSaving ? "Saving..." : "Save to Calendar")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimaryOnBlue)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .cardStyle(
                                    backgroundColor: ThemeColors.accentBlue,
                                    borderColor: ThemeColors.borderBlue,
                                    isChecked: true
                                )
                            }
                            .disabled(isSaving)
                            .opacity(isSaving ? 0.5 : 1.0)
                        }
                        
                        // Habits list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Habits")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            VStack(spacing: 12) {
                                ForEach(habits) { habit in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(habit.title)
                                            .font(ThemeFonts.habitTitle())
                                            .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                        
                                        HStack {
                                            Text(isCompletedToday(habit) ? "Completed today" : "Not completed today")
                                                .font(ThemeFonts.progressMeta())
                                                .foregroundColor(isCompletedToday(habit) ? ThemeColors.accentBlue : ThemeColors.textSecondaryDarkBg)
                                            
                                            Spacer()
                                            
                                            let progress = weeklyProgress(habit)
                                            Text("\(progress.completed)/\(progress.target) this week")
                                                .font(ThemeFonts.progressMeta())
                                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                        }
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cardStyle(
                                        backgroundColor: ThemeColors.cardDark,
                                        borderColor: ThemeColors.borderDark,
                                        isChecked: false
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Daily Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.accentBlue)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, Completion.self, configurations: config)
    
    let habit1 = Habit(title: "Morning Exercise", targetDaysPerWeek: 5)
    let habit2 = Habit(title: "Read for 30 minutes", targetDaysPerWeek: 7)
    let habit3 = Habit(title: "Meditate", targetDaysPerWeek: 6)
    
    container.mainContext.insert(habit1)
    container.mainContext.insert(habit2)
    container.mainContext.insert(habit3)
    
    let todayKey = DayKeyService.todayKey()
    let completion1 = Completion(habitId: habit1.id, dateKey: todayKey)
    container.mainContext.insert(completion1)
    
    return DailySummaryView()
        .modelContainer(container)
}
