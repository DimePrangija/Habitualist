import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var habit: Habit
    
    @State private var title: String = ""
    @State private var targetDaysPerWeek: Int = 7
    @State private var isArchived: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Habit title")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            TextField("Enter habit title", text: $title)
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
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target days per week")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            HStack {
                                Text("\(targetDaysPerWeek) days per week")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                
                                Spacer()
                                
                                Stepper("", value: $targetDaysPerWeek, in: 1...7)
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
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Archive")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isArchived)
                                    .tint(ThemeColors.accentBlue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .cardStyle(
                                backgroundColor: ThemeColors.cardDark,
                                borderColor: ThemeColors.borderDark,
                                isChecked: false
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.textPrimaryDarkBg)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(ThemeColors.accentBlue)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                }
            }
            .onAppear {
                title = habit.title
                targetDaysPerWeek = habit.targetDaysPerWeek
                isArchived = habit.isArchived
            }
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        habit.title = trimmedTitle
        habit.targetDaysPerWeek = targetDaysPerWeek
        habit.isArchived = isArchived
        
        try? modelContext.save()
        dismiss()
    }
}
