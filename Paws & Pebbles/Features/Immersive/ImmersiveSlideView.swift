import SwiftUI

struct ImmersiveSlideView: View {
    let memory: Memory
    @State private var bodyAppeared = false
    @State private var galleryAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                heroSection

                // Body content
                bodyContent
                    .padding(.top, -30)
                    .opacity(bodyAppeared ? 1 : 0)
                    .offset(y: bodyAppeared ? 0 : 24)
            }
            .padding(.bottom, 60)
        }
        .background(AppColors.bgDeep)
        .onAppear {
            withAnimation(AppAnimations.bodyReveal.delay(0.15)) {
                bodyAppeared = true
            }
            withAnimation(AppAnimations.bodyReveal.delay(0.35)) {
                galleryAppeared = true
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Hero image placeholder (stone-colored gradient)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            memory.stoneType.color.opacity(0.3),
                            memory.stoneType.color.opacity(0.15),
                            AppColors.bgDeep
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .aspectRatio(3.0/4.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textDim)
                )

            // Bottom gradient
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.45),
                    .init(color: AppColors.bgDeep.opacity(0.8), location: 0.8),
                    .init(color: AppColors.bgDeep, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Body Content

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Stone badge
            HStack(spacing: 7) {
                Ellipse()
                    .fill(memory.stoneType.color)
                    .frame(width: 9, height: 7)
                Text(memory.stoneType.displayName.uppercased())
                    .font(AppFonts.badge)
                    .tracking(1.8)
                    .foregroundColor(AppColors.river)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(AppColors.river.opacity(0.07))
                    .overlay(Capsule().stroke(AppColors.river.opacity(0.1), lineWidth: 1))
            )

            // Title
            Text(memory.title)
                .font(AppFonts.detailTitle)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(2)

            // Date
            Text(memory.date.formatted(.dateTime.month(.wide).day().year()))
                .font(AppFonts.dateLabelDetail)
                .tracking(2.5)
                .textCase(.uppercase)
                .foregroundColor(AppColors.river.opacity(0.5))

            // Location
            if let location = memory.location {
                HStack(spacing: 7) {
                    Image(systemName: "mappin")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.river.opacity(0.5))
                    Text(location)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.05), lineWidth: 1)
                        )
                )
            }

            // Full story text
            Text(memory.fullText)
                .font(AppFonts.bodyLarge)
                .foregroundColor(AppColors.textMuted)
                .lineSpacing(10)
                .padding(.top, 4)

            // Photo gallery
            gallerySection

            // Mood tags
            if !memory.moods.isEmpty {
                moodTags
            }

            // Swipe hint
            Text("← SWIPE TO NAVIGATE →")
                .font(AppFonts.hint)
                .tracking(2)
                .foregroundColor(AppColors.textDim)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Gallery

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MOMENTS FROM THIS DAY")
                .font(AppFonts.galleryLabel)
                .tracking(2.5)
                .foregroundColor(AppColors.textDim)

            // 2-column staggered grid
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                ForEach(0..<5, id: \.self) { i in
                    let isWide = i == 2

                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    memory.stoneType.color.opacity(0.12),
                                    memory.stoneType.color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(isWide ? 2.0 : 1.0, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.river.opacity(0.04), lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textDim)
                        )
                        .gridCellColumns(isWide ? 2 : 1)
                        .opacity(galleryAppeared ? 1 : 0)
                        .scaleEffect(galleryAppeared ? 1 : 0.92)
                        .animation(
                            AppAnimations.photoReveal.delay(Double(i) * 0.07 + 0.2),
                            value: galleryAppeared
                        )
                }
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Mood Tags

    private var moodTags: some View {
        FlowLayout(spacing: 6) {
            ForEach(memory.moods, id: \.self) { mood in
                Text(mood)
                    .font(AppFonts.mood)
                    .foregroundColor(AppColors.textDim)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.03))
                            .overlay(
                                Capsule().stroke(.white.opacity(0.05), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Flow Layout (wrapping horizontal layout)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}
