import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Habit> { !$0.isArchived },
           sort: \Habit.createdAt)
    private var habits: [Habit]
    
    @State private var todayKey: String = ""
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationStack {
            List {
                Text("Habitualist")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.purple)
                    .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                
                if !todayKey.isEmpty {
                    Text(formatDateHeader())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                }
                
                ForEach(habits) { habit in
                    HabitRowView(habit: habit, todayKey: todayKey)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
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
    
    var body: some View {
        HStack(spacing: 16) {
            HabitStatusIcon(isCompleted: isCompletedToday)
            
            Text(habit.title)
                .font(.system(.body, design: .default, weight: .semibold))
            
            Spacer()
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

