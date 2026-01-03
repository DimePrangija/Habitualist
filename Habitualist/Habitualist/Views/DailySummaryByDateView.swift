import SwiftUI
import SwiftData

struct DailySummaryByDateView: View {
    let selectedDate: Date
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    
    @Query private var completions: [Completion]
    
    private var dateKey: String {
        DayKeyService.dateKey(for: selectedDate)
    }
    
    private var completedCount: Int {
        let dateCompletions = completions.filter { $0.dateKey == dateKey }
        let uniqueHabitIds = Set(dateCompletions.map { $0.habitId })
        return uniqueHabitIds.count
    }
    
    private func isCompletedOnDate(_ habit: Habit) -> Bool {
        completions.contains { $0.habitId == habit.id && $0.dateKey == dateKey }
    }
    
    private func weeklyProgress(_ habit: Habit) -> (completed: Int, target: Int) {
        let completed = WeeklyProgressService.completionsThisWeek(habitId: habit.id, for: selectedDate, in: modelContext)
        return (completed, habit.targetDaysPerWeek)
    }
    
    var body: some View {
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
                                Text("Completed on this date")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                
                                Spacer()
                                
                                Text("\(completedCount)")
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
                                        Text(isCompletedOnDate(habit) ? "Completed on this date" : "Not completed on this date")
                                            .font(ThemeFonts.progressMeta())
                                            .foregroundColor(isCompletedOnDate(habit) ? ThemeColors.accentBlue : ThemeColors.textSecondaryDarkBg)
                                        
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
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    NavigationStack {
        DailySummaryByDateView(selectedDate: Date())
            .modelContainer(for: [Habit.self, Completion.self], inMemory: true)
    }
}
