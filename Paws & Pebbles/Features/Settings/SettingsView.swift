import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("useFaceID") private var useFaceID = true
    @AppStorage("partnerName1") private var partnerName1 = "S"
    @AppStorage("partnerName2") private var partnerName2 = "Natty"
    @AppStorage("anniversaryDate") private var anniversaryTimestamp: Double = {
        var components = DateComponents()
        components.year = 2022
        components.month = 6
        components.day = 20
        return (Calendar.current.date(from: components) ?? Date()).timeIntervalSince1970
    }()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    @State private var showChangePIN = false
    @State private var showResetConfirmation = false
    @State private var anniversaryDate: Date = Date()
    @State private var biometricsAvailable = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Settings")
                    .font(AppFonts.detailTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)

                // Appearance
                section(title: "APPEARANCE") {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Theme").font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                                Text(themeManager.isDarkMode ? "Dark mode" : "Light mode")
                                    .font(AppFonts.badge).foregroundColor(AppColors.textMuted)
                            }
                        } icon: {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(AppColors.river).frame(width: 20)
                        }
                        Spacer()
                        ZStack {
                            Capsule()
                                .fill(AppColors.cardBg)
                                .frame(width: 70, height: 34)
                                .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                            HStack(spacing: 4) {
                                Image(systemName: "sun.max.fill").font(.system(size: 11))
                                    .foregroundColor(themeManager.isDarkMode ? AppColors.textDim : AppColors.river)
                                Spacer()
                                Image(systemName: "moon.fill").font(.system(size: 11))
                                    .foregroundColor(themeManager.isDarkMode ? AppColors.river : AppColors.textDim)
                            }
                            .padding(.horizontal, 10).frame(width: 70)
                            Circle()
                                .fill(AppColors.river)
                                .frame(width: 26, height: 26)
                                .shadow(color: AppColors.river.opacity(0.3), radius: 4)
                                .offset(x: themeManager.isDarkMode ? 16 : -16)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: themeManager.isDarkMode)
                        }
                        .onTapGesture {
                            AppHaptics.photoTap()
                            withAnimation(AppAnimations.snappy) { themeManager.toggle() }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1)))
                }

                // Security
                section(title: "SECURITY") {
                    toggleRow(icon: "faceid", title: "Use Face ID",
                             subtitle: biometricsAvailable ? "Unlock with biometrics" : "Not available",
                             isOn: $useFaceID)
                        .disabled(!biometricsAvailable)

                    buttonRow(icon: "lock.rotation", title: "Change PIN", subtitle: "Update your 4-digit PIN") {
                        showChangePIN = true
                    }
                }

                // Personalization
                section(title: "PERSONALIZATION") {
                    textFieldRow(icon: "person", title: "Your name", text: $partnerName1)
                    textFieldRow(icon: "heart", title: "Their name", text: $partnerName2)

                    VStack(alignment: .leading, spacing: 8) {
                        Label { Text("Anniversary date").font(AppFonts.body).foregroundColor(AppColors.textPrimary) }
                              icon: { Image(systemName: "calendar").foregroundColor(AppColors.river).frame(width: 20) }
                        DatePicker("", selection: $anniversaryDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(AppColors.river)
                            .onChange(of: anniversaryDate) { _, newValue in
                                anniversaryTimestamp = newValue.timeIntervalSince1970
                            }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1))
                    )
                }

                // About
                section(title: "ABOUT") {
                    infoRow(icon: "heart.circle", title: "Paws & Pebbles", value: "v1.0")
                    infoRow(icon: "pawprint", title: "Made with love", value: "for Natty")
                }

                section(title: "") {
                    buttonRow(icon: "arrow.counterclockwise", title: "Reset PIN",
                             subtitle: "Remove current PIN and set a new one", isDestructive: true) {
                        showResetConfirmation = true
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
        .onAppear {
            anniversaryDate = Date(timeIntervalSince1970: anniversaryTimestamp)
            let context = LAContext()
            var error: NSError?
            biometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        }
        .sheet(isPresented: $showChangePIN) {
            ChangePINView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Reset PIN?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                AuthService.shared.savePin("")
                showChangePIN = true
            }
        } message: {
            Text("You'll need to set a new PIN immediately.")
        }
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title).font(AppFonts.badge).tracking(1.5).foregroundColor(AppColors.textMuted)
            }
            content()
        }
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                    Text(subtitle).font(AppFonts.badge).foregroundColor(AppColors.textMuted)
                }
            } icon: { Image(systemName: icon).foregroundColor(AppColors.river).frame(width: 20) }
            Spacer()
            Toggle("", isOn: isOn).tint(AppColors.river).labelsHidden()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1)))
    }

    private func buttonRow(icon: String, title: String, subtitle: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(AppFonts.body).foregroundColor(isDestructive ? .red.opacity(0.8) : AppColors.textPrimary)
                        Text(subtitle).font(AppFonts.badge).foregroundColor(AppColors.textMuted)
                    }
                } icon: { Image(systemName: icon).foregroundColor(isDestructive ? .red.opacity(0.6) : AppColors.river).frame(width: 20) }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textDim)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isDestructive ? Color.red.opacity(0.15) : AppColors.cardBorder, lineWidth: 1)))
    }

    private func textFieldRow(icon: String, title: String, text: Binding<String>) -> some View {
        HStack {
            Label { Text(title).font(AppFonts.body).foregroundColor(AppColors.textPrimary) }
                  icon: { Image(systemName: icon).foregroundColor(AppColors.river).frame(width: 20) }
            Spacer()
            TextField("", text: text).font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.trailing).frame(maxWidth: 120)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1)))
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label { Text(title).font(AppFonts.body).foregroundColor(AppColors.textPrimary) }
                  icon: { Image(systemName: icon).foregroundColor(AppColors.river).frame(width: 20) }
            Spacer()
            Text(value).font(AppFonts.badge).foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1)))
    }
}
