import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var targetDaysPerWeek: Int = 7
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit title", text: $title)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Stepper("Target: \(targetDaysPerWeek) days per week", value: $targetDaysPerWeek, in: 1...7)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let habit = Habit(title: trimmedTitle, targetDaysPerWeek: targetDaysPerWeek)
        modelContext.insert(habit)
        
        try? modelContext.save()
        dismiss()
    }
}

