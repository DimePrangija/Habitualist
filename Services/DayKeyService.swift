import Foundation

struct DayKeyService {
    static func todayKey() -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            // Fallback to current date string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: now)
        }
        
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}

