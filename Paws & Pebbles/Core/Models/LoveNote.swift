import Foundation
import SwiftData

@Model
class LoveNote {
    @Attribute(.unique) var id: UUID
    var message: String
    var date: Date
    var category: NoteCategory
    var openWhenCondition: String?
    var isRevealed: Bool
    var gradientColor1: String
    var gradientColor2: String

    init(message: String, date: Date, category: NoteCategory = .love,
         openWhenCondition: String? = nil, isRevealed: Bool = true,
         gradientColor1: String = "#265e46", gradientColor2: String = "#143328") {
        self.id = UUID()
        self.message = message
        self.date = date
        self.category = category
        self.openWhenCondition = openWhenCondition
        self.isRevealed = isRevealed
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
    }
}

enum NoteCategory: String, Codable {
    case love
    case gratitude
    case memory
    case openWhen
    case justBecause
    case encouragement
}
