import Foundation
import SwiftData

@Model
final class Completion {
    var id: UUID
    var habitId: UUID
    var dateKey: String
    var completedAt: Date
    
    init(habitId: UUID, dateKey: String) {
        self.id = UUID()
        self.habitId = habitId
        self.dateKey = dateKey
        self.completedAt = Date()
    }
}

