import SwiftUI

struct ChangePINView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: PINStep = .verifyOld
    @State private var enteredPin = ""
    @State private var newPin = ""
    @State private var isShaking = false

    enum PINStep { case verifyOld, enterNew, confirmNew }

    private var promptText: String {
        switch step {
        case .verifyOld: return "Enter current PIN"
        case .enterNew: return "Enter new PIN"
        case .confirmNew: return "Confirm new PIN"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(promptText)
                .font(AppFonts.detailTitle)
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 32)

            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < enteredPin.count ? AppColors.river : Color.clear)
                        .overlay(Circle().stroke(AppColors.river.opacity(0.3), lineWidth: 1.5))
                        .frame(width: 14, height: 14)
                }
            }
            .offset(x: isShaking ? -10 : 0)

            VStack(spacing: 14) {
                ForEach(0..<3) { row in
                    HStack(spacing: 20) {
                        ForEach(1...3, id: \.self) { col in numberButton(row * 3 + col) }
                    }
                }
                HStack(spacing: 20) {
                    Color.clear.frame(width: 64, height: 64)
                    numberButton(0)
                    Button { if !enteredPin.isEmpty { enteredPin.removeLast() } } label: {
                        Image(systemName: "delete.left").font(.system(size: 18))
                            .foregroundColor(AppColors.textPrimary).frame(width: 64, height: 64)
                    }
                }
            }
            Spacer()
        }
        .background(AppColors.bgDeep)
    }

    private func numberButton(_ number: Int) -> some View {
        Button {
            guard enteredPin.count < 4 else { return }
            enteredPin += "\(number)"
            AppHaptics.photoTap()
            if enteredPin.count == 4 { handleComplete() }
        } label: {
            Text("\(number)")
                .font(.system(size: 24, weight: .light, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 64, height: 64)
                .background(Circle().fill(AppColors.cardBg))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func handleComplete() {
        switch step {
        case .verifyOld:
            if AuthService.shared.verifyPin(enteredPin) { enteredPin = ""; withAnimation { step = .enterNew } }
            else { shakeAndReset() }
        case .enterNew:
            newPin = enteredPin; enteredPin = ""; withAnimation { step = .confirmNew }
        case .confirmNew:
            if enteredPin == newPin { AuthService.shared.savePin(newPin); AppHaptics.explore(); dismiss() }
            else { shakeAndReset(); withAnimation { step = .enterNew } }
        }
    }

    private func shakeAndReset() {
        withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) { isShaking = true }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isShaking = false; enteredPin = "" }
    }
}
