import Foundation
import SwiftData

struct DataService {
    static func loadInitialDataIfNeeded(context: ModelContext) {
        loadMemories(context: context)
        loadNotes(context: context)
        loadAlbums(context: context)
        loadCountdowns(context: context)
        loadPuppies(context: context)
    }

    // MARK: - Memories

    private static func loadMemories(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Memory>())) ?? 0
        guard count == 0 else { return }
        guard let dtos = loadJSON([MemoryDTO].self, from: "memories") else { return }

        for dto in dtos {
            let memory = Memory(
                title: dto.title,
                snippet: dto.snippet,
                fullText: dto.fullText,
                date: dto.parsedDate,
                stoneType: StoneType(rawValue: dto.stoneType) ?? .sandstone,
                location: dto.location,
                moods: dto.moods,
                isMilestone: dto.isMilestone,
                hasPawPrint: dto.hasPawPrint,
                heroImageFilename: dto.heroImageFilename,
                photoFilenames: dto.photoFilenames,
                galleryFilenames: dto.galleryFilenames,
                sortOrder: dto.sortOrder
            )
            context.insert(memory)
        }
        try? context.save()
    }

    // MARK: - Notes

    private static func loadNotes(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<LoveNote>())) ?? 0
        guard count == 0 else { return }
        guard let dtos = loadJSON([NoteDTO].self, from: "notes") else { return }

        for dto in dtos {
            let note = LoveNote(
                message: dto.message,
                date: dto.parsedDate,
                category: NoteCategory(rawValue: dto.category) ?? .love,
                openWhenCondition: dto.openWhenCondition,
                isRevealed: dto.isRevealed ?? true,
                gradientColor1: dto.gradientColor1 ?? "#265e46",
                gradientColor2: dto.gradientColor2 ?? "#143328"
            )
            context.insert(note)
        }
        try? context.save()
    }

    // MARK: - Albums

    private static func loadAlbums(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Album>())) ?? 0
        guard count == 0 else { return }
        guard let dtos = loadJSON([AlbumDTO].self, from: "albums") else { return }

        for dto in dtos {
            let album = Album(
                title: dto.title,
                subtitle: dto.subtitle,
                coverImageFilename: dto.coverImageFilename,
                date: dto.parsedDate,
                mediaFilenames: dto.mediaFilenames,
                gradientColor1: dto.gradientColor1 ?? "#265e46",
                gradientColor2: dto.gradientColor2 ?? "#143328"
            )
            context.insert(album)
        }
        try? context.save()
    }

    // MARK: - Countdowns

    private static func loadCountdowns(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Countdown>())) ?? 0
        guard count == 0 else { return }
        guard let dtos = loadJSON([CountdownDTO].self, from: "countdowns") else { return }

        for dto in dtos {
            let countdown = Countdown(
                title: dto.title,
                targetDate: dto.parsedDate,
                emoji: dto.emoji ?? "💕",
                gradientColor1: dto.gradientColor1 ?? "#1a5c42",
                gradientColor2: dto.gradientColor2 ?? "#0c3626"
            )
            context.insert(countdown)
        }
        try? context.save()
    }

    // MARK: - Puppies

    private static func loadPuppies(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Puppy>())) ?? 0
        guard count == 0 else { return }
        guard let dtos = loadJSON([PuppyDTO].self, from: "puppies") else { return }

        for dto in dtos {
            let puppy = Puppy(
                name: dto.name,
                photoFilename: dto.photoFilename,
                message: dto.message,
                years: dto.years
            )
            context.insert(puppy)
        }
        try? context.save()
    }

    // MARK: - JSON Loader

    private static func loadJSON<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: data)
    }
}

// MARK: - DTOs

private struct MemoryDTO: Decodable {
    let title: String
    let snippet: String
    let fullText: String
    let date: String
    let stoneType: String
    let location: String?
    let moods: [String]
    let isMilestone: Bool
    let hasPawPrint: Bool
    let heroImageFilename: String
    let photoFilenames: [String]
    let galleryFilenames: [String]
    let sortOrder: Int
    var parsedDate: Date { ISO8601DateFormatter().date(from: date) ?? Date() }
}

private struct NoteDTO: Decodable {
    let message: String
    let date: String
    let category: String
    let openWhenCondition: String?
    let isRevealed: Bool?
    let gradientColor1: String?
    let gradientColor2: String?
    var parsedDate: Date { ISO8601DateFormatter().date(from: date) ?? Date() }
}

private struct AlbumDTO: Decodable {
    let title: String
    let subtitle: String?
    let coverImageFilename: String
    let date: String
    let mediaFilenames: [String]
    let gradientColor1: String?
    let gradientColor2: String?
    var parsedDate: Date { ISO8601DateFormatter().date(from: date) ?? Date() }
}

private struct CountdownDTO: Decodable {
    let title: String
    let targetDate: String
    let emoji: String?
    let gradientColor1: String?
    let gradientColor2: String?
    var parsedDate: Date { ISO8601DateFormatter().date(from: targetDate) ?? Date() }
}

private struct PuppyDTO: Decodable {
    let name: String
    let photoFilename: String
    let message: String
    let years: String?
}
