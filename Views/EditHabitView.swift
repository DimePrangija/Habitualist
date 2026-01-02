import SwiftUI
import SwiftData

struct EditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var habit: Habit
    
    @State private var title: String = ""
    @State private var isArchived: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit title", text: $title)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Toggle("Archive", isOn: $isArchived)
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                title = habit.title
                isArchived = habit.isArchived
            }
        }
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        habit.title = trimmedTitle
        habit.isArchived = isArchived
        
        try? modelContext.save()
        dismiss()
    }
}

