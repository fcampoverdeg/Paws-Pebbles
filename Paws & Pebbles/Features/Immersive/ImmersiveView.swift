import SwiftUI
import SwiftData

struct ImmersiveView: View {
    let memories: [Memory]
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.bgDeep.ignoresSafeArea()

            // Horizontal paging
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                        ImmersiveSlideView(memory: memory)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: Binding(
                get: { memories.indices.contains(currentIndex) ? memories[currentIndex].id : nil },
                set: { newId in
                    if let newId, let idx = memories.firstIndex(where: { $0.id == newId }) {
                        if idx != currentIndex {
                            AppHaptics.slide()
                            currentIndex = idx
                        }
                    }
                }
            ))

            // Navigation overlay
            navigationBar
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack {
            // Back button
            Button {
                AppHaptics.back()
                withAnimation(.easeInOut(duration: 0.55)) {
                    isPresented = false
                }
            } label: {
                navButton(icon: "arrow.left")
            }

            Spacer()

            // Counter
            Text("\(currentIndex + 1) / \(memories.count)")
                .font(AppFonts.counter)
                .tracking(1)
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(AppColors.bgDeep.opacity(0.55))
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(.white.opacity(0.05), lineWidth: 1)
                        )
                )

            Spacer()

            // Prev / Next
            HStack(spacing: 8) {
                Button {
                    guard currentIndex > 0 else { return }
                    AppHaptics.slide()
                    withAnimation(AppAnimations.primary) {
                        currentIndex -= 1
                    }
                } label: {
                    navButton(icon: "chevron.left")
                        .opacity(currentIndex == 0 ? 0.25 : 1)
                }
                .disabled(currentIndex == 0)

                Button {
                    guard currentIndex < memories.count - 1 else { return }
                    AppHaptics.slide()
                    withAnimation(AppAnimations.primary) {
                        currentIndex += 1
                    }
                } label: {
                    navButton(icon: "chevron.right")
                        .opacity(currentIndex == memories.count - 1 ? 0.25 : 1)
                }
                .disabled(currentIndex == memories.count - 1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 52)
    }

    private func navButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AppColors.textPrimary)
            .frame(width: 38, height: 38)
            .background(
                Circle()
                    .fill(AppColors.bgDeep.opacity(0.55))
                    .background(.ultraThinMaterial.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(.white.opacity(0.07), lineWidth: 1)
                    )
            )
    }
}
