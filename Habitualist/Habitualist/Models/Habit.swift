import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var title: String
    var createdAt: Date
    var isArchived: Bool
    var targetDaysPerWeek: Int
    
    init(title: String, targetDaysPerWeek: Int = 7) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.isArchived = false
        self.targetDaysPerWeek = targetDaysPerWeek
    }
}

