import SwiftUI

enum StoneType: String, Codable, CaseIterable {
    case sandstone
    case slate
    case mossy
    case quartz
    case obsidian

    var displayName: String {
        switch self {
        case .sandstone: return "Sandstone"
        case .slate: return "River slate"
        case .mossy: return "Mossy stone"
        case .quartz: return "Rose quartz"
        case .obsidian: return "Obsidian"
        }
    }

    var color: Color {
        switch self {
        case .sandstone: return AppColors.sandstone
        case .slate: return AppColors.slate
        case .mossy: return AppColors.mossyStone
        case .quartz: return AppColors.roseQuartz
        case .obsidian: return AppColors.obsidian
        }
    }
}
