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
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Appearance section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Appearance")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(AppearanceMode.allCases.enumerated()), id: \.element) { index, mode in
                                    HStack {
                                        Text(mode.rawValue)
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                        
                                        Spacer()
                                        
                                        if appearanceMode == mode {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(ThemeColors.accentBlue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        appearanceMode = mode
                                    }
                                    
                                    if index < AppearanceMode.allCases.count - 1 {
                                        Rectangle()
                                            .fill(ThemeColors.divider)
                                            .frame(height: 1)
                                            .padding(.leading, 16)
                                    }
                                }
                            }
                            .cardStyle(
                                backgroundColor: ThemeColors.cardDark,
                                borderColor: ThemeColors.borderDark,
                                isChecked: false
                            )
                        }
                        
                        // Calendar section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calendar")
                                .font(ThemeFonts.sectionLabel())
                                .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                .textCase(.uppercase)
                                .tracking(1.2)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Write daily summary to Calendar")
                                        .font(.system(size: 17, weight: .regular, design: .rounded))
                                        .foregroundColor(ThemeColors.textPrimaryDarkBg)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $writeDailySummaryToCalendar)
                                        .tint(ThemeColors.accentBlue)
                                        .onChange(of: writeDailySummaryToCalendar) { oldValue, newValue in
                                            if newValue {
                                                Task {
                                                    await handleCalendarToggleOn()
                                                }
                                            }
                                        }
                                }
                                .padding(16)
                                .cardStyle(
                                    backgroundColor: ThemeColors.cardDark,
                                    borderColor: ThemeColors.borderDark,
                                    isChecked: false
                                )
                                
                                if writeDailySummaryToCalendar {
                                    Text("Daily summaries will be saved to the Habitualist calendar in Apple Calendar.")
                                        .font(ThemeFonts.progressMeta())
                                        .foregroundColor(ThemeColors.textSecondaryDarkBg)
                                        .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.accentBlue)
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

#Preview {
    SettingsView()
}
