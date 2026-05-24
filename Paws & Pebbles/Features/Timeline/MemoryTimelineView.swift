import SwiftUI
import SwiftData

struct MemoryTimelineView: View {
    @Query(sort: \Memory.sortOrder) private var memories: [Memory]
    @State private var activeIndex: Int = 0
    @State private var appeared = false
    @Binding var selectedMemoryIndex: Int?

    private let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.bgDeep.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                        CarouselCard(
                            memory: memory,
                            isActive: index == activeIndex,
                            index: index,
                            appeared: appeared,
                            onExplore: {
                                AppHaptics.explore()
                                selectedMemoryIndex = index
                            }
                        )
                        .id(index)
                        // Each card gets a fixed container height so snapping works
                        .frame(height: screenHeight * 0.55)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .hidesTabBarOnScroll()
            .scrollPosition(id: Binding(
                get: { activeIndex },
                set: { newIndex in
                    if let newIndex, newIndex != activeIndex {
                        withAnimation(AppAnimations.foldUnfold) {
                            activeIndex = newIndex
                        }
                        AppHaptics.cardUnfold()
                    }
                }
            ))
            .safeAreaPadding(.top, screenHeight * 0.28)
            .safeAreaPadding(.bottom, screenHeight * 0.25)

            // Header
            header
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(AppAnimations.cardEntrance) { appeared = true }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                Text("Paws ")
                    .font(AppFonts.appTitle)
                    .foregroundColor(AppColors.textPrimary)
                Text("&")
                    .font(Font.custom("CormorantGaramond-Italic", size: 30))
                    .foregroundColor(AppColors.river)
                Text(" Pebbles")
                    .font(AppFonts.appTitle)
                    .foregroundColor(AppColors.textPrimary)
            }

            HStack {
                Text("OUR RIVER OF MEMORIES")
                    .font(AppFonts.subtitle)
                    .tracking(3.5)
                    .foregroundColor(AppColors.textMuted)

                Spacer()

                Text("\(activeIndex + 1) / \(memories.count)")
                    .font(AppFonts.badge)
                    .foregroundColor(AppColors.river.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(AppColors.river.opacity(0.08))
                            .overlay(Capsule().stroke(AppColors.river.opacity(0.1), lineWidth: 1))
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 56)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                stops: [
                    .init(color: AppColors.bgDeep, location: 0),
                    .init(color: AppColors.bgDeep, location: 0.5),
                    .init(color: AppColors.bgDeep.opacity(0.9), location: 0.8),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Carousel Card

struct CarouselCard: View {
    let memory: Memory
    let isActive: Bool
    let index: Int
    let appeared: Bool
    let onExplore: () -> Void

    @State private var scrollScale: CGFloat = 0.88
    @State private var scrollOpacity: Double = 0.5

    var body: some View {
        MemoryContainerView(
            memory: memory,
            isActive: isActive,
            index: index,
            appeared: appeared,
            onExplore: onExplore
        )
        .padding(.horizontal, 4)
        .scaleEffect(scrollScale)
        .opacity(scrollOpacity)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .global).midY) { _, midY in
                        updateEffects(midY: midY)
                    }
                    .onAppear {
                        updateEffects(midY: geo.frame(in: .global).midY)
                    }
            }
        )
    }

    private func updateEffects(midY: CGFloat) {
        let screenMid = UIScreen.main.bounds.height * 0.45
        let distance = abs(midY - screenMid)
        let maxDist = UIScreen.main.bounds.height * 0.3
        let progress = min(distance / maxDist, 1.0)

        withAnimation(.interactiveSpring(response: 0.12)) {
            scrollScale = 1.0 - progress * 0.12
            scrollOpacity = 1.0 - progress * 0.5
        }
    }
}
