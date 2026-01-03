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
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 0) {
                        Text("Habitualist")
                            .font(ThemeFonts.screenTitle())
                            .foregroundColor(ThemeColors.accentBlue)
                        
                        Spacer()
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(ThemeColors.textPrimaryDarkBg)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.leading, 8)
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                    .background(ThemeColors.background)
                    
                    // Divider
                    Rectangle()
                        .fill(ThemeColors.divider)
                        .frame(height: 1)
                    
                    // List
                    ScrollView {
                        VStack(spacing: 12) {
                            Button {
                                showingAddHabit = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(ThemeColors.accentBlue)
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(ThemeColors.textPrimaryOnBlue)
                                    }
                                    
                                    Text("Add new habits")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .cardStyle(
                                    backgroundColor: ThemeColors.cardDark,
                                    borderColor: ThemeColors.borderDark,
                                    isChecked: false
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            if !todayKey.isEmpty {
                                Text(formatDateHeader())
                                    .font(ThemeFonts.progressMeta())
                                    .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                            }
                            
                            Button {
                                showingDailySummary = true
                            } label: {
                                Text("Daily Summary")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .cardStyle(
                                        backgroundColor: ThemeColors.cardDark,
                                        borderColor: ThemeColors.borderDark,
                                        isChecked: false
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            ForEach(habits) { habit in
                                HabitRowView(habit: habit, todayKey: todayKey)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Color.clear
                }
            }
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
    
    private var isChecked: Bool {
        isWeekCompleted || isCompletedToday
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Title and progress
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(ThemeFonts.habitTitle())
                    .foregroundColor(isChecked ? ThemeColors.textPrimaryOnBlue : ThemeColors.textPrimaryDarkBg)
                
                Text("\(weeklyCount)/\(habit.targetDaysPerWeek) this week")
                    .font(ThemeFonts.progressMeta())
                    .foregroundColor(isChecked ? ThemeColors.textSecondaryOnBlue : ThemeColors.textSecondaryDarkBg)
            }
            
            Spacer()
            
            // Right side: Circular status button
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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

#Preview {
    TodayView()
        .modelContainer(for: [Habit.self, Completion.self], inMemory: true)
}
