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
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("What habits do you want to track?")
                        .font(ThemeFonts.screenTitle())
                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            // Text field styled as dark card
                            TextField("Habit title", text: $currentTitle)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .cardStyle(
                                    backgroundColor: ThemeColors.cardDark,
                                    borderColor: ThemeColors.borderDark,
                                    isChecked: false
                                )
                                .autocorrectionDisabled()
                            
                            // Stepper row styled as dark card
                            HStack {
                                Text("Target: \(currentTarget) days per week")
                                    .font(ThemeFonts.progressMeta())
                                    .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                
                                Spacer()
                                
                                Stepper("", value: $currentTarget, in: 1...7)
                                    .labelsHidden()
                                    .tint(ThemeColors.accentBlue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .cardStyle(
                                backgroundColor: ThemeColors.cardDark,
                                borderColor: ThemeColors.borderDark,
                                isChecked: false
                            )
                            
                            Button("Add") {
                                addHabit()
                            }
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimaryOnBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .cardStyle(
                                backgroundColor: ThemeColors.accentBlue,
                                borderColor: ThemeColors.borderBlue,
                                isChecked: true
                            )
                            .disabled(currentTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(currentTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                        }
                        
                        if !habits.isEmpty {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(habits) { habit in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(habit.title)
                                                    .font(ThemeFonts.habitTitle())
                                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                                Text("\(habit.targetDaysPerWeek) days per week")
                                                    .font(ThemeFonts.progressMeta())
                                                    .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .frame(minHeight: 78)
                                        .cardStyle(
                                            backgroundColor: ThemeColors.cardDark,
                                            borderColor: ThemeColors.borderDark,
                                            isChecked: false
                                        )
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button("Get Started") {
                        saveHabitsAndComplete()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(ThemeColors.textPrimaryOnBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .cardStyle(
                        backgroundColor: ThemeColors.accentBlue,
                        borderColor: ThemeColors.borderBlue,
                        isChecked: true
                    )
                    .disabled(habits.isEmpty)
                    .opacity(habits.isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
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
