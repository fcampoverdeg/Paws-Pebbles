import Foundation
import SwiftData

@Model
class Countdown {
    @Attribute(.unique) var id: UUID
    var title: String
    var targetDate: Date
    var emoji: String
    var gradientColor1: String
    var gradientColor2: String

    init(title: String, targetDate: Date, emoji: String = "💕",
         gradientColor1: String = "#1a5c42", gradientColor2: String = "#0c3626") {
        self.id = UUID()
        self.title = title
        self.targetDate = targetDate
        self.emoji = emoji
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
    }
}
