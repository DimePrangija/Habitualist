import SwiftUI
import EventKit

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("writeDailySummaryToCalendar") private var writeDailySummaryToCalendar: Bool = false
    
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                Section {
                    Toggle("Write daily summary to Calendar", isOn: $writeDailySummaryToCalendar)
                        .onChange(of: writeDailySummaryToCalendar) { oldValue, newValue in
                            if newValue {
                                Task {
                                    await handleCalendarToggleOn()
                                }
                            }
                        }
                    
                    if writeDailySummaryToCalendar {
                        Text("Daily summaries will be saved to the Habitualist calendar in Apple Calendar.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Calendar")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Calendar Access Required", isPresented: $showingPermissionAlert) {
                Button("OK") {
                    writeDailySummaryToCalendar = false
                }
            } message: {
                Text(permissionAlertMessage)
            }
        }
    }
    
    private func handleCalendarToggleOn() async {
        let granted = await CalendarEventService.shared.requestAccessIfNeeded()
        
        if !granted {
            await MainActor.run {
                permissionAlertMessage = "Calendar access is required to save daily summaries. Please enable it in Settings."
                showingPermissionAlert = true
                writeDailySummaryToCalendar = false
            }
        }
    }
}
