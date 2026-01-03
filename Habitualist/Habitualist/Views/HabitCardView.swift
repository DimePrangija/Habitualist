import SwiftUI
import SwiftData

struct HabitCardView: View {
    let habit: Habit
    let todayKey: String
    
    @Environment(\.modelContext) private var modelContext
    @Query private var completions: [Completion]
    
    private var isCompletedToday: Bool {
        completions.contains { $0.habitId == habit.id && $0.dateKey == todayKey }
    }
    
    private var weeklyCount: Int {
        WeeklyProgressService.completionsThisWeek(habitId: habit.id, for: Date(), in: modelContext)
    }
    
    private var isWeekCompleted: Bool {
        WeeklyProgressService.isWeekCompleted(habit, for: Date(), in: modelContext)
    }
    
    private var isChecked: Bool {
        isWeekCompleted || isCompletedToday
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Title and progress
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(isChecked ? ThemeColors.textPrimaryOnBlue : ThemeColors.textPrimaryDarkBg)
                
                Text("\(weeklyCount)/\(habit.targetDaysPerWeek) this week")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(isChecked ? ThemeColors.textSecondaryOnBlue : ThemeColors.textSecondaryDarkBg)
            }
            
            Spacer()
            
            // Right side: Circular toggle button
            Button {
                toggleCompletion()
            } label: {
                ZStack {
                    Circle()
                        .fill(isChecked ? Color.black.opacity(0.22) : Color.white.opacity(0.10))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: isChecked ? "checkmark" : "xmark")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .frame(minHeight: 78)
        .cardStyle(
            backgroundColor: isChecked ? ThemeColors.accentBlue : ThemeColors.cardDark,
            borderColor: isChecked ? ThemeColors.borderBlue : ThemeColors.borderDark,
            isChecked: isChecked
        )
        .contentShape(Rectangle())
        .onTapGesture {
            toggleCompletion()
        }
    }
    
    private func toggleCompletion() {
        let existingCompletion = completions.first { $0.habitId == habit.id && $0.dateKey == todayKey }
        
        if let completion = existingCompletion {
            modelContext.delete(completion)
        } else {
            let newCompletion = Completion(habitId: habit.id, dateKey: todayKey)
            modelContext.insert(newCompletion)
        }
        
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, Completion.self, configurations: config)
    
    let habit = Habit(title: "Morning Exercise", targetDaysPerWeek: 5)
    container.mainContext.insert(habit)
    
    let todayKey = DayKeyService.todayKey()
    let completion = Completion(habitId: habit.id, dateKey: todayKey)
    container.mainContext.insert(completion)
    
    return HabitCardView(habit: habit, todayKey: todayKey)
        .modelContainer(container)
        .padding()
        .background(ThemeColors.background)
}
