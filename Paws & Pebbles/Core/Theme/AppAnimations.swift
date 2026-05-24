import SwiftUI

enum AppAnimations {
    // Primary spring — slight overshoot, natural
    static let primary = Animation.spring(response: 0.55, dampingFraction: 0.72, blendDuration: 0)

    // Snappy
    static let snappy = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    // Gentle
    static let gentle = Animation.spring(response: 0.65, dampingFraction: 0.85, blendDuration: 0)

    // Card fold/unfold
    static let foldUnfold = Animation.spring(response: 0.55, dampingFraction: 0.72, blendDuration: 0)

    // Photo reveal stagger base
    static let photoReveal = Animation.spring(response: 0.45, dampingFraction: 0.78, blendDuration: 0)

    // Entrance stagger
    static let cardEntrance = Animation.spring(response: 0.7, dampingFraction: 0.78, blendDuration: 0)

    // Immersive body
    static let bodyReveal = Animation.spring(response: 0.65, dampingFraction: 0.8, blendDuration: 0)
}

enum AppHaptics {
    static func cardUnfold() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func cardFold() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    static func explore() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func slide() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    static func back() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    static func photoTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
