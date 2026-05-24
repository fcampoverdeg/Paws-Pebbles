import SwiftUI

struct LockScreenView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var isUnlocked: Bool
    @AppStorage("pinEnabled") private var pinEnabled = true
    @AppStorage("pinLength") private var pinLength = 4
    @AppStorage("useFaceID") private var useFaceID = true
    @State private var enteredPin = ""
    @State private var isShaking = false
    @State private var showSuccess = false
    @State private var breatheScale: CGFloat = 1.0
    @State private var isSettingPin = false
    @State private var appeared = false
    @State private var ringRotation: Double = 0

    var body: some View {
        ZStack {
            AppColors.bgDeep.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Paw print icon with glow
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [AppColors.river.opacity(0.2), .clear, AppColors.river.opacity(0.1), .clear],
                                center: .center
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(ringRotation))

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppColors.river.opacity(0.12), .clear],
                                center: .center, startRadius: 20, endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(breatheScale)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.river)
                        .scaleEffect(breatheScale)
                }

                VStack(spacing: 8) {
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
                    .opacity(appeared ? 1 : 0)

                    Text("YOUR STORY, ONE PEBBLE AT A TIME")
                        .font(AppFonts.subtitle)
                        .tracking(3.5)
                        .foregroundColor(AppColors.textMuted)
                        .opacity(appeared ? 1 : 0)
                }

                // PIN dots
                HStack(spacing: 18) {
                    ForEach(0..<pinLength, id: \.self) { index in
                        ZStack {
                            Circle()
                                .stroke(AppColors.river.opacity(0.3), lineWidth: 1.5)
                                .frame(width: 16, height: 16)

                            Circle()
                                .fill(showSuccess ? AppColors.gold : AppColors.river)
                                .frame(width: 16, height: 16)
                                .scaleEffect(index < enteredPin.count ? 1 : 0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: enteredPin.count)
                        }
                    }
                }
                .offset(x: isShaking ? -12 : 0)

                if isSettingPin {
                    Text("SET YOUR PIN")
                        .font(AppFonts.button)
                        .tracking(1.5)
                        .foregroundColor(AppColors.textMuted)
                }

                // Number pad
                VStack(spacing: 14) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 22) {
                            ForEach(1...3, id: \.self) { col in
                                numberButton(row * 3 + col)
                            }
                        }
                    }
                    HStack(spacing: 22) {
                        Color.clear.frame(width: 68, height: 68)
                        numberButton(0)
                        Button {
                            if !enteredPin.isEmpty { enteredPin.removeLast() }
                        } label: {
                            Image(systemName: "delete.left")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 68, height: 68)
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)

                // Face ID
                Button {
                    AuthService.shared.authenticateWithBiometrics { success in
                        if success { unlockSuccess() }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "faceid")
                            .font(.system(size: 14))
                        Text("USE FACE ID")
                            .font(AppFonts.button)
                            .tracking(1.5)
                    }
                    .foregroundColor(AppColors.textMuted)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.cardBg)
                            .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                    )
                }
                .opacity(appeared ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            // Skip lock screen if PIN is disabled
            if !pinEnabled {
                isUnlocked = true
                return
            }

            isSettingPin = !AuthService.shared.hasPin()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) { appeared = true }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { breatheScale = 1.08 }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { ringRotation = 360 }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Only trigger Face ID when app becomes active (user is looking at the app)
            if newPhase == .active && !isUnlocked && !isSettingPin && useFaceID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AuthService.shared.authenticateWithBiometrics { success in
                        if success { unlockSuccess() }
                    }
                }
            }
        }
    }

    private func numberButton(_ number: Int) -> some View {
        Button {
            guard enteredPin.count < pinLength else { return }
            enteredPin += "\(number)"
            AppHaptics.photoTap()
            if enteredPin.count == pinLength { validatePin() }
        } label: {
            Text("\(number)")
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 72, height: 72)
                .overlay(
                    Circle()
                        .stroke(AppColors.textPrimary.opacity(0.15), lineWidth: 1.5)
                )
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func validatePin() {
        if isSettingPin {
            AuthService.shared.savePin(enteredPin)
            unlockSuccess()
        } else if AuthService.shared.verifyPin(enteredPin) {
            unlockSuccess()
        } else {
            withAnimation(.default.repeatCount(5, autoreverses: true).speed(6)) { isShaking = true }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isShaking = false; enteredPin = "" }
        }
    }

    private func unlockSuccess() {
        showSuccess = true
        AppHaptics.explore()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { isUnlocked = true }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
