import SwiftUI

struct ThemeColors {
    // Background colors
    static let background = Color(hex: "2F2F2F")
    static let cardDark = Color(hex: "343434")
    static let accentBlue = Color(hex: "A0CCD8")
    
    // Text colors on dark background
    static let textPrimaryDarkBg = Color.white
    static let textSecondaryDarkBg = Color.white.opacity(0.65)
    
    // Text colors on blue card
    static let textPrimaryOnBlue = Color(hex: "1E1E1E")
    static let textSecondaryOnBlue = Color(hex: "1E1E1E").opacity(0.65)
    
    // Border colors
    static let borderDark = Color.white.opacity(0.12)
    static let borderBlue = Color.black.opacity(0.08)
    
    // Divider
    static let divider = Color.white.opacity(0.08)
}

struct ThemeFonts {
    // Screen title
    static func screenTitle() -> Font {
        .system(size: 34, weight: .heavy, design: .rounded)
    }
    
    // Section label (uppercase style)
    static func sectionLabel() -> Font {
        .system(size: 14, weight: .bold, design: .rounded)
    }
    
    // Habit title
    static func habitTitle() -> Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }
    
    // Progress meta text
    static func progressMeta() -> Font {
        .system(size: 13, weight: .regular, design: .rounded)
    }
}

extension View {
    func cardStyle(backgroundColor: Color, borderColor: Color, isChecked: Bool) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
