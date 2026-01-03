import SwiftUI
import SwiftData

struct MonthCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived })
    private var habits: [Habit]
    @Query private var completions: [Completion]
    
    @State private var displayedDate: Date
    @Binding var selectedDate: Date?
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private var todayKey: String {
        DayKeyService.todayKey()
    }
    
    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: displayedDate)) ?? displayedDate
    }
    
    private var monthEnd: Date {
        calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? displayedDate
    }
    
    private var firstDayOfMonth: Date {
        monthStart
    }
    
    private var firstWeekday: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // ISO calendar: Monday = 1, Sunday = 7
        // Convert to 0-based index where Monday = 0
        return (weekday + 5) % 7
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: displayedDate)?.count ?? 30
    }
    
    private var completionDateKeys: Set<String> {
        let startKey = DayKeyService.dateKey(for: monthStart)
        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthEnd
        let endKey = DayKeyService.dateKey(for: calendar.date(byAdding: .day, value: -1, to: nextMonthStart) ?? monthEnd)
        
        return Set(completions
            .filter { $0.dateKey >= startKey && $0.dateKey <= endKey }
            .map { $0.dateKey })
    }
    
    private func isAllCompleted(for dateKey: String) -> Bool {
        guard !habits.isEmpty else { return false }
        
        let habitIds = Set(habits.map { $0.id })
        let completedHabitIds = Set(completions
            .filter { $0.dateKey == dateKey }
            .map { $0.habitId })
        
        return habitIds.isSubset(of: completedHabitIds)
    }
    
    init(selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
        self._displayedDate = State(initialValue: Date())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        displayedDate = calendar.date(byAdding: .month, value: -1, to: displayedDate) ?? displayedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                }
                
                Spacer()
                
                Text(monthFormatter.string(from: displayedDate))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                
                Spacer()
                
                Button {
                    withAnimation {
                        displayedDate = calendar.date(byAdding: .month, value: 1, to: displayedDate) ?? displayedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .cardStyle(
                backgroundColor: ThemeColors.cardDark,
                borderColor: ThemeColors.borderDark,
                isChecked: false
            )
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondaryDarkBg)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Empty cells for days before month start
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }
                
                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
                    let dateKey = DayKeyService.dateKey(for: date)
                    
                    DayCell(
                        day: day,
                        date: date,
                        isToday: dateKey == todayKey,
                        hasCompletion: completionDateKeys.contains(dateKey),
                        isAllCompleted: isAllCompleted(for: dateKey)
                    ) {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(16)
        .cardStyle(
            backgroundColor: ThemeColors.cardDark,
            borderColor: ThemeColors.borderDark,
            isChecked: false
        )
    }
}

struct DayCell: View {
    let day: Int
    let date: Date
    let isToday: Bool
    let hasCompletion: Bool
    let isAllCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: 16, weight: isToday ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isAllCompleted ? ThemeColors.textPrimaryOnBlue : ThemeColors.textPrimaryDarkBg)
                
                if hasCompletion && !isAllCompleted {
                    Circle()
                        .fill(ThemeColors.accentBlue)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isAllCompleted ? ThemeColors.accentBlue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isAllCompleted ? ThemeColors.accentBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MonthCalendarView(selectedDate: .constant(nil))
        .modelContainer(for: [Habit.self, Completion.self], inMemory: true)
        .padding()
        .background(ThemeColors.background)
}
