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
                    
                    // Card Feed
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            Button {
                                showingAddHabit = true
                            } label: {
                                Text("Add new habits")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                HabitCardView(habit: habit, todayKey: todayKey)
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

#Preview {
    TodayView()
        .modelContainer(for: [Habit.self, Completion.self], inMemory: true)
}
