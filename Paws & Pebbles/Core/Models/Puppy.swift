import Foundation
import SwiftData

@Model
class Puppy {
    @Attribute(.unique) var id: UUID
    var name: String
    var photoFilename: String
    var message: String
    var years: String?

    init(name: String, photoFilename: String, message: String, years: String? = nil) {
        self.id = UUID()
        self.name = name
        self.photoFilename = photoFilename
        self.message = message
        self.years = years
    }
}
