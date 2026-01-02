import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @State private var todayKey: String = ""
    @State private var showingAddHabit = false
    @State private var showingSettings = false
    @State private var showingDailySummary = false
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Habitualist")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            showingAddHabit = true
                        } label: {
                            Text("Add new habits")
                                .font(.body)
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                
                if !todayKey.isEmpty {
                    Text(formatDateHeader())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                }
                
                Button {
                    showingDailySummary = true
                } label: {
                    Text("Daily Summary")
                        .frame(maxWidth: .infinity)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                ForEach(habits) { habit in
                    HabitRowView(habit: habit, todayKey: todayKey)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingDailySummary) {
                DailySummaryView()
            }
            .onAppear {
                todayKey = DayKeyService.todayKey()
            }
        }
    }
    
    private func formatDateHeader() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}

struct HabitRowView: View {
    let habit: Habit
    let todayKey: String
    
    @Environment(\.modelContext) private var modelContext
    @Query private var completions: [Completion]
    @State private var showingEditHabit = false
    
    private var isCompletedToday: Bool {
        completions.contains { $0.habitId == habit.id && $0.dateKey == todayKey }
    }
    
    private var weeklyCount: Int {
        WeeklyProgressService.completionsThisWeek(habitId: habit.id, for: Date(), in: modelContext)
    }
    
    private var isWeekCompleted: Bool {
        WeeklyProgressService.isWeekCompleted(habit, for: Date(), in: modelContext)
    }
    
    private var shouldShowGreen: Bool {
        isWeekCompleted || isCompletedToday
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(.body, design: .default, weight: .semibold))
                    
                    Text("\(weeklyCount)/\(habit.targetDaysPerWeek) this week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HabitStatusIcon(isCompleted: shouldShowGreen)
            }
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleCompletion()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showingEditHabit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showingEditHabit) {
            EditHabitView(habit: habit)
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

