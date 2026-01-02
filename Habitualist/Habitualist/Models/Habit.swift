import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var title: String
    var createdAt: Date
    var isArchived: Bool
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.isArchived = false
    }
}

