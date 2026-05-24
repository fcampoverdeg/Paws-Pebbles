import SwiftUI

struct PhotoEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let image: Image
    @Binding var offset: CGSize
    @Binding var savedOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var savedScale: CGFloat
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var pinchScale: CGFloat = 1.0

    init(image: UIImage, offset: Binding<CGSize>, savedOffset: Binding<CGSize>,
         scale: Binding<CGFloat>, savedScale: Binding<CGFloat>,
         onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.image = Image(uiImage: image)
        self._offset = offset
        self._savedOffset = savedOffset
        self._scale = scale
        self._savedScale = savedScale
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar — always tappable, never blocked by gestures
            topBar
                .zIndex(10)

            // Photo area — gestures only here
            photoArea
                .zIndex(1)

            // Bottom bar
            bottomBar
                .zIndex(10)
        }
        .background(Color.black.ignoresSafeArea())
        .statusBarHidden()
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                onCancel()
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
                )
            }

            Spacer()

            Text("ADJUST PHOTO")
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            Button {
                savedOffset = offset
                savedScale = scale
                onSave()
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Done")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(AppColors.river)
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 58)
        .padding(.bottom, 16)
        .background(Color.black)
    }

    // MARK: - Photo Area (gesture zone)

    private var photoArea: some View {
        GeometryReader { geo in
            image
                .resizable()
                .scaledToFill()
                .scaleEffect(scale * pinchScale)
                .offset(
                    x: offset.width + dragOffset.width,
                    y: offset.height + dragOffset.height
                )
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            offset = CGSize(
                                width: offset.width + dragOffset.width,
                                height: offset.height + dragOffset.height
                            )
                            dragOffset = .zero
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            pinchScale = value.magnification
                        }
                        .onEnded { value in
                            scale = max(0.5, min(3.0, scale * value.magnification))
                            pinchScale = 1.0
                        }
                )
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Text("PINCH TO ZOOM  •  DRAG TO MOVE")
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            // Reset button
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    offset = .zero
                    scale = 1.0
                    pinchScale = 1.0
                    dragOffset = .zero
                }
            } label: {
                Text("RESET")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.08))
                            .overlay(Capsule().stroke(.white.opacity(0.1), lineWidth: 1))
                    )
            }
        }
        .padding(.bottom, 40)
        .padding(.top, 16)
        .background(Color.black)
    }
}
