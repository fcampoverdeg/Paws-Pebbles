import SwiftUI

struct SurprisesView: View {
    @State private var crackedGeodes: Set<Int> = []

    private let surprises: [(title: String, message: String)] = [
        ("Crystal Geode", "You are my favorite adventure."),
        ("Ancient Fossil", "Our love is written in stone."),
        ("Time Capsule", "A surprise for our next anniversary...")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hidden Gems")
                    .font(AppFonts.detailTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                Text("LONG PRESS TO REVEAL")
                    .font(AppFonts.subtitle)
                    .tracking(3.5)
                    .foregroundColor(AppColors.textMuted)
                    .padding(.horizontal, 20)

                ForEach(Array(surprises.enumerated()), id: \.offset) { index, surprise in
                    let isCracked = crackedGeodes.contains(index)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(surprise.title)
                                .font(AppFonts.memoryTitle)
                                .foregroundColor(isCracked ? AppColors.river : AppColors.textPrimary)
                            Spacer()
                            Image(systemName: isCracked ? "sparkles" : "diamond")
                                .foregroundColor(isCracked ? AppColors.gold : AppColors.textDim)
                        }

                        if isCracked {
                            Text(surprise.message)
                                .font(Font.custom("CormorantGaramond-Italic", size: 18))
                                .foregroundColor(AppColors.textPrimary)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        } else {
                            Text("Long press to crack open...")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textDim)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isCracked ? AppColors.river.opacity(0.06) : AppColors.cardBg)
                            .overlay(RoundedRectangle(cornerRadius: 18)
                                .stroke(isCracked ? AppColors.river.opacity(0.15) : AppColors.cardBorder, lineWidth: 1))
                    )
                    .padding(.horizontal, 20)
                    .onLongPressGesture(minimumDuration: 1.0) {
                        AppHaptics.explore()
                        withAnimation(AppAnimations.primary) { crackedGeodes.insert(index) }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(AppColors.bgDeep)
    }
}
