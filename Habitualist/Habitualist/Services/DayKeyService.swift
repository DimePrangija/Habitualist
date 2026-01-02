import Foundation

struct DayKeyService {
    private static var calendar: Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    static func todayKey() -> String {
        return dateKey(for: Date())
    }
    
    static func dateKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date)
        }
        
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    static func weekStartDate(for date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
    
    static func weekKey(for date: Date) -> String {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let year = components.yearForWeekOfYear,
              let week = components.weekOfYear else {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-'W'ww"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date)
        }
        
        return String(format: "%04d-W%02d", year, week)
    }
}

