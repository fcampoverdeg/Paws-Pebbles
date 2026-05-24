import SwiftUI

enum PINMode {
    case setup
    case change
}

struct GlassPINView: View {
    @Environment(\.dismiss) private var dismiss
    let mode: PINMode
    let pinLength: Int
    var onComplete: (() -> Void)?

    @State private var step: Step = .enterNew
    @State private var enteredPin = ""
    @State private var newPin = ""
    @State private var isShaking = false
    @State private var appeared = false

    private var storedPinLength: Int {
        AuthService.shared.getStoredPinLength()
    }

    // How many dots to show for the current step
    private var dotsCount: Int {
        switch step {
        case .verifyOld: return storedPinLength > 0 ? storedPinLength : 4
        case .enterNew: return 6  // Show max dots, fill as user types
        case .confirmNew: return newPin.count
        }
    }

    // When does the step auto-advance?
    private var autoAdvanceAt: Int? {
        switch step {
        case .verifyOld: return storedPinLength > 0 ? storedPinLength : 4
        case .enterNew: return nil  // User decides length (4-6), taps confirm
        case .confirmNew: return newPin.count
        }
    }

    enum Step {
        case verifyOld, enterNew, confirmNew
    }

    init(mode: PINMode, pinLength: Int, onComplete: (() -> Void)? = nil) {
        self.mode = mode
        self.pinLength = pinLength
        self.onComplete = onComplete
        self._step = State(initialValue: mode == .change ? .verifyOld : .enterNew)
    }

    private var promptText: String {
        switch step {
        case .verifyOld: return "Enter current PIN"
        case .enterNew: return "Choose your new PIN"
        case .confirmNew: return "Confirm your PIN"
        }
    }

    private var hintText: String? {
        switch step {
        case .enterNew:
            if enteredPin.count >= 4 {
                return "Tap confirm when ready (\(enteredPin.count) digits)"
            }
            return "Enter 4 to 6 digits"
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            AppColors.bgDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Cancel")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(.clear, in: .capsule)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)

                Spacer()

                // Prompt
                Text(promptText)
                    .font(Font.custom("CormorantGaramond-Regular", size: 26))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.bottom, 8)

                // Hint
                if let hint = hintText {
                    Text(hint)
                        .font(AppFonts.badge)
                        .foregroundColor(AppColors.river.opacity(0.7))
                        .padding(.bottom, 16)
                } else {
                    Spacer().frame(height: 24)
                }

                // PIN dots
                HStack(spacing: 14) {
                    ForEach(0..<dotsCount, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPin.count ? AppColors.river : AppColors.river.opacity(0.2))
                            .frame(width: 14, height: 14)
                            .scaleEffect(index < enteredPin.count ? 1.0 : 0.7)
                            .animation(.bouncy(duration: 0.3, extraBounce: 0.15), value: enteredPin.count)
                    }
                }
                .offset(x: isShaking ? -12 : 0)
                .padding(.bottom, 32)

                // Confirm button (only in enterNew step when >= 4 digits)
                if step == .enterNew && enteredPin.count >= 4 {
                    Button {
                        newPin = enteredPin
                        enteredPin = ""
                        withAnimation(.bouncy(duration: 0.4)) { step = .confirmNew }
                        AppHaptics.photoTap()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                            Text("CONFIRM")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(1.5)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(AppColors.river))
                    }
                    .padding(.bottom, 20)
                    .transition(.scale.combined(with: .opacity))
                }

                // Glass numpad
                glassNumpad

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    // MARK: - Glass Numpad

    private var glassNumpad: some View {
        VStack(spacing: 14) {
            ForEach(0..<3) { row in
                HStack(spacing: 20) {
                    ForEach(1...3, id: \.self) { col in
                        glassNumberButton(row * 3 + col)
                    }
                }
            }
            HStack(spacing: 20) {
                Color.clear.frame(width: 72, height: 72)
                glassNumberButton(0)
                Button {
                    if !enteredPin.isEmpty { enteredPin.removeLast() }
                } label: {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 72, height: 72)
                        .glassEffect(.clear.interactive(), in: .circle)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private func glassNumberButton(_ number: Int) -> some View {
        Button {
            let maxLen = autoAdvanceAt ?? 6
            guard enteredPin.count < maxLen else { return }
            enteredPin += "\(number)"
            AppHaptics.photoTap()

            if let advanceAt = autoAdvanceAt, enteredPin.count == advanceAt {
                handleComplete()
            }
        } label: {
            Text("\(number)")
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .glassEffect(.clear.interactive(), in: .circle)
        }
    }

    // MARK: - Logic

    private func handleComplete() {
        switch step {
        case .verifyOld:
            if AuthService.shared.verifyPin(enteredPin) {
                enteredPin = ""
                withAnimation(.bouncy(duration: 0.4)) { step = .enterNew }
            } else {
                shakeAndReset()
            }
        case .enterNew:
            // Handled by confirm button
            break
        case .confirmNew:
            if enteredPin == newPin {
                AuthService.shared.savePin(newPin)
                // Save the new length
                UserDefaults.standard.set(newPin.count, forKey: "pinLength")
                AppHaptics.explore()
                onComplete?()
                dismiss()
            } else {
                shakeAndReset()
                withAnimation(.bouncy(duration: 0.4)) { step = .enterNew }
            }
        }
    }

    private func shakeAndReset() {
        withAnimation(.default.repeatCount(5, autoreverses: true).speed(6)) {
            isShaking = true
        }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
            enteredPin = ""
        }
    }
}
