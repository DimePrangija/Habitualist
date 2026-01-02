import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var habitTitles: [String] = []
    @State private var currentTitle: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What habits do you want to track?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        TextField("Habit title", text: $currentTitle)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        Button("Add") {
                            addHabit()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(currentTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    if !habitTitles.isEmpty {
                        List {
                            ForEach(Array(habitTitles.enumerated()), id: \.offset) { index, title in
                                HStack {
                                    Text(title)
                                        .font(.body)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .onDelete { indexSet in
                                habitTitles.remove(atOffsets: indexSet)
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
                .disabled(habitTitles.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func addHabit() {
        let trimmed = currentTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        habitTitles.append(trimmed)
        currentTitle = ""
    }
    
    private func saveHabitsAndComplete() {
        guard !habitTitles.isEmpty else { return }
        
        for title in habitTitles {
            let habit = Habit(title: title)
            modelContext.insert(habit)
        }
        
        try? modelContext.save()
    }
}
