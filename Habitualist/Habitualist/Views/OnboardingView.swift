import SwiftUI
import SwiftData

struct HabitInput: Identifiable {
    let id = UUID()
    var title: String
    var targetDaysPerWeek: Int
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var habits: [HabitInput] = []
    @State private var currentTitle: String = ""
    @State private var currentTarget: Int = 7
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What habits do you want to track?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        TextField("Habit title", text: $currentTitle)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        HStack {
                            Text("Target: \(currentTarget) days per week")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Stepper("", value: $currentTarget, in: 1...7)
                                .labelsHidden()
                        }
                        
                        Button("Add") {
                            addHabit()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(currentTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    if !habits.isEmpty {
                        List {
                            ForEach(habits) { habit in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.title)
                                            .font(.body)
                                        Text("\(habit.targetDaysPerWeek) days per week")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .onDelete { indexSet in
                                habits.remove(atOffsets: indexSet)
                            }
                        }
                        .frame(maxHeight: 300)
                        .scrollContentBackground(.hidden)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Get Started") {
                    saveHabitsAndComplete()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(habits.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func addHabit() {
        let trimmed = currentTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        habits.append(HabitInput(title: trimmed, targetDaysPerWeek: currentTarget))
        currentTitle = ""
        currentTarget = 7
    }
    
    private func saveHabitsAndComplete() {
        guard !habits.isEmpty else { return }
        
        for habitInput in habits {
            let habit = Habit(title: habitInput.title, targetDaysPerWeek: habitInput.targetDaysPerWeek)
            modelContext.insert(habit)
        }
        
        try? modelContext.save()
    }
}
