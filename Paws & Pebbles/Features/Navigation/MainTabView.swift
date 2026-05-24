import SwiftUI
import SwiftData
import Combine

// Shared scroll state so pages can hide the tab bar
class TabBarVisibility: ObservableObject {
    @Published var isVisible: Bool = true
    private var lastOffset: CGFloat = 0
    private var accumulatedDelta: CGFloat = 0

    func onScroll(offset: CGFloat) {
        let delta = offset - lastOffset
        lastOffset = offset

        guard abs(delta) > 0.5 else { return }

        // Near the top — always show
        if offset < 50 {
            if !isVisible {
                withAnimation(.bouncy(duration: 0.5, extraBounce: 0.15)) {
                    isVisible = true
                }
            }
            accumulatedDelta = 0
            return
        }

        accumulatedDelta += delta

        // Positive delta = content moving up = user scrolling down = hide
        if accumulatedDelta > 20 && isVisible {
            withAnimation(.bouncy(duration: 0.45, extraBounce: 0.1)) {
                isVisible = false
            }
            accumulatedDelta = 0
        }

        // Negative delta = scrolling up = show, but ONLY if near the top
        if accumulatedDelta < -15 && !isVisible && offset < 80 {
            withAnimation(.bouncy(duration: 0.5, extraBounce: 0.15)) {
                isVisible = true
            }
            accumulatedDelta = 0
        }

        // Reset on direction change
        if (delta > 0 && accumulatedDelta < 0) || (delta < 0 && accumulatedDelta > 0) {
            accumulatedDelta = 0
        }
    }
}

struct TabBarScrollDetector: ViewModifier {
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newOffset in
                tabBarVisibility.onScroll(offset: newOffset)
            }
    }
}

extension View {
    func hidesTabBarOnScroll() -> some View {
        self.modifier(TabBarScrollDetector())
    }
}

struct MainTabView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Query(sort: \Memory.sortOrder) private var memories: [Memory]
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @State private var selectedTab: Int = 0
    @State private var showImmersive = false
    @State private var immersiveIndex: Int = 0
    @State private var edgeSwipeOffset: CGFloat = 0
    @State private var isEdgeSwiping = false

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("circle.circle", "Timeline"),
        ("photo.on.rectangle", "Gallery"),
        ("heart.fill", "Notes"),
        ("gearshape.fill", "Settings")
    ]

    var body: some View {
        ZStack {
            AppColors.bgDeep.ignoresSafeArea()

            ZStack {
                if showImmersive {
                    ImmersiveView(
                        memories: memories,
                        currentIndex: $immersiveIndex,
                        isPresented: $showImmersive
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    pageContent
                        .offset(x: edgeSwipeOffset)
                        .overlay(alignment: .leading) {
                            // Left edge drag zone
                            Color.clear
                                .frame(width: 40)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isEdgeSwiping = true
                                            let dx = value.translation.width
                                            if selectedTab <= 0 {
                                                edgeSwipeOffset = dx * 0.15
                                            } else {
                                                edgeSwipeOffset = max(0, dx)
                                            }
                                        }
                                        .onEnded { value in
                                            isEdgeSwiping = false
                                            let dx = value.translation.width
                                            if dx > 80 && selectedTab > 0 {
                                                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.12)) {
                                                    selectedTab -= 1
                                                    edgeSwipeOffset = 0
                                                }
                                                AppHaptics.slide()
                                            } else {
                                                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.15)) {
                                                    edgeSwipeOffset = 0
                                                }
                                            }
                                        }
                                )
                        }
                        .overlay(alignment: .trailing) {
                            // Right edge drag zone
                            Color.clear
                                .frame(width: 40)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isEdgeSwiping = true
                                            let dx = value.translation.width
                                            if selectedTab >= tabs.count - 1 {
                                                edgeSwipeOffset = dx * 0.15
                                            } else {
                                                edgeSwipeOffset = min(0, dx)
                                            }
                                        }
                                        .onEnded { value in
                                            isEdgeSwiping = false
                                            let dx = value.translation.width
                                            if dx < -80 && selectedTab < tabs.count - 1 {
                                                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.12)) {
                                                    selectedTab += 1
                                                    edgeSwipeOffset = 0
                                                }
                                                AppHaptics.slide()
                                            } else {
                                                withAnimation(.bouncy(duration: 0.4, extraBounce: 0.15)) {
                                                    edgeSwipeOffset = 0
                                                }
                                            }
                                        }
                                )
                        }
                }
            }
            .animation(.easeInOut(duration: 0.55), value: showImmersive)

            if !showImmersive {
                VStack {
                    Spacer()
                    liquidGlassTabBar
                        .scaleEffect(
                            x: tabBarVisibility.isVisible ? 1.0 : 0.0,
                            y: tabBarVisibility.isVisible ? 1.0 : 0.8
                        )
                        .opacity(tabBarVisibility.isVisible ? 1.0 : 0.0)
                        .offset(y: tabBarVisibility.isVisible ? 0 : 20)
                }
            }
        }
        .environmentObject(tabBarVisibility)
        .onChange(of: selectedTab) { _, _ in
            // Always show bar when switching tabs
            withAnimation(.bouncy(duration: 0.4)) {
                tabBarVisibility.isVisible = true
            }
        }
    }

    private var timelineTab: some View {
        MemoryTimelineView(
            selectedMemoryIndex: Binding(
                get: { nil },
                set: { index in
                    if let index {
                        immersiveIndex = index
                        showImmersive = true
                    }
                }
            )
        )
    }

    // MARK: - Page Content (slides with pill drag)

    // All tab views — kept alive to avoid first-load lag
    @State private var preloadedTabs = false

    @ViewBuilder
    private func tabView(for index: Int) -> some View {
        switch index {
        case 0: HomeView()
        case 1: timelineTab
        case 2: GalleryView()
        case 3: NotesListView()
        case 4: SettingsView()
        default: HomeView()
        }
    }

    private var pageContent: some View {
        let frac = pageFractionalIndex
        let fromIndex = max(0, min(tabs.count - 1, Int(floor(frac))))
        let toIndex = max(0, min(tabs.count - 1, Int(ceil(frac))))
        let t = (fromIndex == toIndex) ? 0.0 : frac - CGFloat(fromIndex)
        let screenW = UIScreen.main.bounds.width

        return ZStack {
            // Pre-load all tabs hidden so they're ready
            ForEach(0..<tabs.count, id: \.self) { index in
                tabView(for: index)
                    .opacity(index == fromIndex || index == toIndex ? 1 : 0)
                    .zIndex(index == fromIndex || index == toIndex ? 1 : 0)
                    .offset(x: tabOffset(for: index, from: fromIndex, to: toIndex, t: t, screenW: screenW))
                    .allowsHitTesting(index == selectedTab && !isDragging)
            }
        }
        .clipped()
    }

    private func tabOffset(for index: Int, from: Int, to: Int, t: CGFloat, screenW: CGFloat) -> CGFloat {
        if index == from {
            return -t * screenW
        } else if index == to && from != to {
            return screenW * (1.0 - t)
        } else {
            return index < selectedTab ? -screenW : screenW
        }
    }

    // Same as pill fractional index but for page tracking
    private var pageFractionalIndex: CGFloat {
        guard slotWidth > 0 else { return CGFloat(selectedTab) }
        if isDragging {
            let localX = dragX + barWidth / 2 - barPadding
            return max(0, min(CGFloat(tabs.count - 1), localX / slotWidth - 0.5))
        }
        return CGFloat(selectedTab)
    }

    // MARK: - Liquid Glass Tab Bar State

    @State private var isDragging = false
    @State private var dragX: CGFloat = 0
    @State private var dragStartX: CGFloat = 0
    @State private var barWidth: CGFloat = 0

    private let pillSize: CGFloat = 54
    private let barPadding: CGFloat = 8

    private var slotWidth: CGFloat {
        guard tabs.count > 0, barWidth > 0 else { return 60 }
        return (barWidth - barPadding * 2) / CGFloat(tabs.count)
    }

    private func pillX(for index: Int) -> CGFloat {
        barPadding + slotWidth * (CGFloat(index) + 0.5) - barWidth / 2
    }

    private func nearestTab(at x: CGFloat) -> Int {
        let localX = x + barWidth / 2
        return max(0, min(tabs.count - 1, Int((localX - barPadding) / slotWidth)))
    }

    private var isDark: Bool { themeManager.isDarkMode }

    private var liquidGlassTabBar: some View {
        ZStack {
            // Unselected icons
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Group {
                        if selectedTab != index {
                            Image(systemName: tab.icon)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(
                                    isDark
                                        ? Color.white.opacity(0.3)
                                        : Color(hex: "#2A3A32").opacity(0.45)
                                )
                        } else {
                            Color.clear
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, barPadding)

            // Glass pill with refraction icons
            pillContent
            .frame(width: pillSize * 1.35, height: pillSize * 0.88)
            .glassEffect(
                .clear.tint(
                    isDark
                        ? AppColors.river.opacity(0.08)
                        : AppColors.river.opacity(0.06)
                ).interactive(),
                in: .capsule
            )
            .scaleEffect(isDragging ? 1.08 : 1.0)
            .offset(x: isDragging ? dragX : pillX(for: selectedTab))
            .animation(isDragging ? .interactiveSpring(response: 0.08) :
                    .bouncy(duration: 0.5, extraBounce: 0.2), value: selectedTab)
            .animation(.bouncy(duration: 0.4, extraBounce: 0.15), value: isDragging)
            .allowsHitTesting(false)
        }
        .frame(height: 60)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: isDark ? .clear : Color(hex: "#8A9A90").opacity(0.18), location: 0),
                            .init(color: isDark ? .clear : Color(hex: "#C8D4CC").opacity(0.06), location: 0.3),
                            .init(color: isDark ? .clear : Color(hex: "#C8D4CC").opacity(0.06), location: 0.7),
                            .init(color: isDark ? .clear : Color(hex: "#8A9A90").opacity(0.18), location: 1)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        )
        .glassEffect(
            .regular.tint(
                isDark
                    ? Color(hex: "#0E1A24").opacity(0.55)
                    : Color(hex: "#9AABA2").opacity(0.1)
            ),
            in: .capsule
        )
        .contentShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        dragStartX = pillX(for: selectedTab)
                    }
                    dragX = dragStartX + value.translation.width

                    let lo = pillX(for: 0)
                    let hi = pillX(for: tabs.count - 1)
                    dragX = max(lo, min(hi, dragX))

                    let newTab = nearestTab(at: dragX)
                    if newTab != selectedTab {
                        selectedTab = newTab
                        AppHaptics.slide()
                    }
                }
                .onEnded { _ in
                    withAnimation(.bouncy(duration: 0.5, extraBounce: 0.2)) {
                        isDragging = false
                    }
                }
        )
        .simultaneousGesture(
            // Tap to select — detect which tab was tapped by location
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded { value in
                    guard !isDragging else { return }
                    let tapX = value.location.x
                    let localBarWidth = barWidth
                    guard localBarWidth > 0 else { return }
                    let tappedIndex = Int(tapX / (localBarWidth / CGFloat(tabs.count)))
                    let clamped = max(0, min(tabs.count - 1, tappedIndex))
                    withAnimation(.bouncy(duration: 0.45, extraBounce: 0.15)) {
                        selectedTab = clamped
                    }
                    AppHaptics.photoTap()
                }
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 2)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { barWidth = geo.size.width - 64 }
            }
        )
    }

    // MARK: - Pill Content (refraction effect)

    // Continuous fractional position: 0.0 = first tab, 1.0 = second tab, etc.
    private var pillFractionalIndex: CGFloat {
        guard slotWidth > 0 else { return CGFloat(selectedTab) }
        let currentX = isDragging ? dragX : pillX(for: selectedTab)
        let localX = currentX + barWidth / 2 - barPadding
        return localX / slotWidth - 0.5
    }

    @ViewBuilder
    private var pillContent: some View {
        let frac = pillFractionalIndex
        let fromIndex = max(0, min(tabs.count - 1, Int(floor(frac))))
        let toIndex = max(0, min(tabs.count - 1, Int(ceil(frac))))

        // 0 = fully on fromIndex, 1 = fully on toIndex
        let t: CGFloat = (fromIndex == toIndex) ? 0 : frac - CGFloat(fromIndex)
        let halfW = pillSize * 0.55

        // Direction: pill moving from fromIndex toward toIndex (left to right)
        let movingRight = toIndex >= fromIndex

        ZStack {
            // FROM icon — starts centered, slides out opposite to movement
            Image(systemName: tabs[fromIndex].icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.river.opacity(1.0 - t))
                .shadow(color: AppColors.river.opacity(0.5 * (1.0 - t)), radius: 6)
                .offset(x: movingRight
                    ? -t * halfW        // exits left as pill moves right
                    :  t * halfW        // exits right as pill moves left
                )
                .scaleEffect(1.0 - t * 0.3)

            // TO icon — enters from edge, slides to center
            if fromIndex != toIndex {
                Image(systemName: tabs[toIndex].icon)
                    .font(.system(size: 14 + t * 6, weight: .medium))
                    .foregroundColor(AppColors.river.opacity(t))
                    .shadow(color: AppColors.river.opacity(t * 0.4), radius: t * 5)
                    .offset(x: movingRight
                        ?  halfW * (1.0 - t)    // enters from right, reaches center at t=1
                        : -halfW * (1.0 - t)    // enters from left, reaches center at t=1
                    )
                    .scaleEffect(0.6 + t * 0.4)
            }
        }
        .clipShape(Capsule())
    }
}
