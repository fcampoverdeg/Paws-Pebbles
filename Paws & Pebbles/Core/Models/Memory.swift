import Foundation
import SwiftData

@Model
class Memory {
    @Attribute(.unique) var id: UUID
    var title: String
    var snippet: String
    var fullText: String
    var date: Date
    var stoneType: StoneType
    var location: String?
    var moods: [String]
    var isMilestone: Bool
    var hasPawPrint: Bool
    var heroImageFilename: String
    var photoFilenames: [String]
    var galleryFilenames: [String]
    var sortOrder: Int

    init(title: String, snippet: String, fullText: String, date: Date,
         stoneType: StoneType = .sandstone, location: String? = nil,
         moods: [String] = [], isMilestone: Bool = false, hasPawPrint: Bool = false,
         heroImageFilename: String = "", photoFilenames: [String] = [],
         galleryFilenames: [String] = [], sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.snippet = snippet
        self.fullText = fullText
        self.date = date
        self.stoneType = stoneType
        self.location = location
        self.moods = moods
        self.isMilestone = isMilestone
        self.hasPawPrint = hasPawPrint
        self.heroImageFilename = heroImageFilename
        self.photoFilenames = photoFilenames
        self.galleryFilenames = galleryFilenames
        self.sortOrder = sortOrder
    }
}
