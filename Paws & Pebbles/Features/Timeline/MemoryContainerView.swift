import SwiftUI

struct MemoryContainerView: View {
    let memory: Memory
    let isActive: Bool
    let index: Int
    let appeared: Bool
    let onExplore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Collapsed header (always visible)
            collapsedHeader

            // Expanded content (only when active)
            if isActive {
                expandedContent
                    .transition(.asymmetric(
                        insertion: .opacity
                            .combined(with: .move(edge: .top))
                            .combined(with: .scale(scale: 0.97, anchor: .top)),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.97, anchor: .top))
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppColors.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(isActive ? AppColors.cardActive : AppColors.cardBorder, lineWidth: 1)
                )
                .shadow(
                    color: isActive ? AppColors.river.opacity(0.08) : .clear,
                    radius: isActive ? 24 : 0,
                    y: 4
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal, 12)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(
            AppAnimations.cardEntrance.delay(Double(index) * 0.08),
            value: appeared
        )
    }

    // MARK: - Collapsed Header

    private var collapsedHeader: some View {
        HStack(spacing: 14) {
            // Stone color dot with glow
            ZStack {
                Circle()
                    .fill(memory.stoneType.color.opacity(isActive ? 0.2 : 0))
                    .frame(width: 24, height: 24)

                Ellipse()
                    .fill(memory.stoneType.color)
                    .frame(width: 10, height: 8)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(memory.date.formatted(.dateTime.month().day().year()))
                    .font(AppFonts.dateLabel)
                    .tracking(2)
                    .textCase(.uppercase)
                    .foregroundColor(AppColors.river.opacity(0.5))

                Text(memory.title)
                    .font(AppFonts.memoryTitle)
                    .foregroundColor(isActive ? AppColors.textPrimary : AppColors.textMuted)
                    .lineLimit(isActive ? 3 : 1)
                    .animation(.easeOut(duration: 0.3), value: isActive)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? AppColors.river : AppColors.textDim)
                .rotationEffect(.degrees(isActive ? 180 : 0))
                .animation(AppAnimations.snappy, value: isActive)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Photo row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        memory.stoneType.color.opacity(0.15),
                                        memory.stoneType.color.opacity(0.05)
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 112)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppColors.river.opacity(0.06), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.textDim)
                            )
                            .scaleEffect(isActive ? 1 : 0.9)
                            .opacity(isActive ? 1 : 0)
                            .animation(
                                AppAnimations.photoReveal.delay(Double(i) * 0.06 + 0.08),
                                value: isActive
                            )
                    }
                }
                .padding(.horizontal, 18)
            }

            // Location
            if let location = memory.location {
                HStack(spacing: 6) {
                    Image(systemName: "mappin")
                        .font(.system(size: 9))
                        .foregroundColor(AppColors.river.opacity(0.4))
                    Text(location)
                        .font(AppFonts.location)
                        .foregroundColor(AppColors.textDim)
                }
                .padding(.horizontal, 18)
            }

            // Snippet
            Text(memory.snippet)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textMuted)
                .lineSpacing(5)
                .padding(.horizontal, 18)

            // Explore button
            Button(action: onExplore) {
                HStack(spacing: 8) {
                    Text("EXPLORE THIS MEMORY")
                        .font(AppFonts.button)
                        .tracking(1.5)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.river)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(AppColors.river.opacity(0.08))
                        .overlay(Capsule().stroke(AppColors.river.opacity(0.15), lineWidth: 1))
                )
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
    }
}
