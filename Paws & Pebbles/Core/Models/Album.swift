import Foundation
import SwiftData

@Model
class Album {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String?
    var coverImageFilename: String
    var date: Date
    var mediaFilenames: [String]
    var gradientColor1: String
    var gradientColor2: String

    init(title: String, subtitle: String? = nil, coverImageFilename: String,
         date: Date, mediaFilenames: [String] = [],
         gradientColor1: String = "#265e46", gradientColor2: String = "#143328") {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.coverImageFilename = coverImageFilename
        self.date = date
        self.mediaFilenames = mediaFilenames
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
    }
}
