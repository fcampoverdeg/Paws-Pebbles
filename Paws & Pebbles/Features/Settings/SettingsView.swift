import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("useFaceID") private var useFaceID = true
    @AppStorage("pinEnabled") private var pinEnabled = true
    @AppStorage("pinLength") private var pinLength = 4
    @AppStorage("partnerName1") private var partnerName1 = "Sebi"
    @AppStorage("partnerName2") private var partnerName2 = "Natty"
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("parallaxEnabled") private var parallaxEnabled = true
    @AppStorage("dailyNotificationEnabled") private var dailyNotificationEnabled = false
    @AppStorage("dailyNotificationHour") private var dailyNotificationHour = 9
    @AppStorage("lockDelay") private var lockDelay = 0 // 0 = immediately

    @State private var showChangePIN = false
    @State private var showSetupPIN = false
    @State private var showClearDataConfirm = false
    @State private var biometricsAvailable = false

    private let lockDelayOptions = [
        (0, "Immediately"),
        (30, "After 30 seconds"),
        (60, "After 1 minute"),
        (300, "After 5 minutes")
    ]

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
                    // Theme toggle
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
                            Capsule().fill(AppColors.cardBg).frame(width: 70, height: 34)
                                .overlay(Capsule().stroke(AppColors.cardBorder, lineWidth: 1))
                            HStack(spacing: 4) {
                                Image(systemName: "sun.max.fill").font(.system(size: 11))
                                    .foregroundColor(themeManager.isDarkMode ? AppColors.textDim : AppColors.river)
                                Spacer()
                                Image(systemName: "moon.fill").font(.system(size: 11))
                                    .foregroundColor(themeManager.isDarkMode ? AppColors.river : AppColors.textDim)
                            }
                            .padding(.horizontal, 10).frame(width: 70)
                            Circle().fill(AppColors.river).frame(width: 26, height: 26)
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
                    .settingsCard()

                    // Parallax
                    toggleRow(icon: "cube.transparent", title: "3D Parallax",
                             subtitle: "Photo moves when you tilt the phone", isOn: $parallaxEnabled)

                    // Haptics
                    toggleRow(icon: "waveform", title: "Haptics",
                             subtitle: "Vibration feedback on interactions", isOn: $hapticsEnabled)
                }

                // Security
                section(title: "SECURITY") {
                    // PIN toggle
                    toggleRow(icon: "lock.fill", title: "PIN Lock",
                             subtitle: pinEnabled ? "\(pinLength)-digit PIN active" : "No PIN set",
                             isOn: Binding(
                                get: { pinEnabled },
                                set: { newValue in
                                    if newValue { showSetupPIN = true }
                                    else { pinEnabled = false; AuthService.shared.savePin("") }
                                }
                             ))

                    if pinEnabled {
                        buttonRow(icon: "lock.rotation", title: "Change PIN",
                                 subtitle: "Set a new PIN (4-6 digits)") {
                            showChangePIN = true
                        }

                        // Lock delay
                        HStack {
                            Label {
                                Text("Lock after closing").font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                            } icon: {
                                Image(systemName: "timer").foregroundColor(AppColors.river).frame(width: 20)
                            }
                            Spacer()
                            Menu {
                                ForEach(lockDelayOptions, id: \.0) { seconds, label in
                                    Button {
                                        lockDelay = seconds
                                    } label: {
                                        HStack {
                                            Text(label)
                                            if lockDelay == seconds {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text(lockDelayOptions.first { $0.0 == lockDelay }?.1 ?? "Immediately")
                                    .font(AppFonts.badge)
                                    .foregroundColor(AppColors.river)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.river)
                            }
                        }
                        .padding(16)
                        .settingsCard()
                    }

                    // Face ID
                    toggleRow(icon: "faceid", title: "Use Face ID",
                             subtitle: biometricsAvailable ? "Unlock with biometrics" : "Not available",
                             isOn: $useFaceID)
                        .disabled(!biometricsAvailable)
                }

                // Notifications
                section(title: "NOTIFICATIONS") {
                    toggleRow(icon: "bell.fill", title: "Daily Pebble",
                             subtitle: "A love note every morning", isOn: $dailyNotificationEnabled)

                    if dailyNotificationEnabled {
                        HStack {
                            Label {
                                Text("Notification time").font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                            } icon: {
                                Image(systemName: "clock").foregroundColor(AppColors.river).frame(width: 20)
                            }
                            Spacer()
                            Picker("", selection: $dailyNotificationHour) {
                                ForEach(6..<23) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .tint(AppColors.river)
                        }
                        .padding(16)
                        .settingsCard()
                    }
                }

                // Personalization
                section(title: "PERSONALIZATION") {
                    textFieldRow(icon: "person", title: "Your name", text: $partnerName1)
                    textFieldRow(icon: "heart", title: "Their name", text: $partnerName2)

                    // Anniversary — hardcoded, display only
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Anniversary").font(AppFonts.body).foregroundColor(AppColors.textPrimary)
                                Text("The day it all began").font(AppFonts.badge).foregroundColor(AppColors.textMuted)
                            }
                        } icon: {
                            Image(systemName: "heart.circle").foregroundColor(AppColors.river).frame(width: 20)
                        }
                        Spacer()
                        Text("June 20, 2022")
                            .font(Font.custom("CormorantGaramond-Italic", size: 16))
                            .foregroundColor(AppColors.river)
                    }
                    .padding(16)
                    .settingsCard()
                }

                // Data
                section(title: "DATA") {
                    buttonRow(icon: "square.and.arrow.up", title: "Export Memories",
                             subtitle: "Save a backup of your data") {
                        // TODO: export
                    }

                    buttonRow(icon: "trash", title: "Clear All Data",
                             subtitle: "Remove all memories and notes", isDestructive: true) {
                        showClearDataConfirm = true
                    }
                }

                // About
                section(title: "ABOUT") {
                    infoRow(icon: "heart.circle", title: "Paws & Pebbles", value: "v1.0")
                    infoRow(icon: "pawprint", title: "Made with love", value: "for Wifie Paws")
                }

                Spacer(minLength: 140)
            }
            .padding(.horizontal, 20)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
        .onAppear {
            let context = LAContext()
            var error: NSError?
            biometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        }
        .fullScreenCover(isPresented: $showChangePIN) {
            GlassPINView(mode: .change, pinLength: pinLength)
        }
        .fullScreenCover(isPresented: $showSetupPIN) {
            GlassPINView(mode: .setup, pinLength: pinLength) {
                pinEnabled = true
            }
        }
        .alert("Clear All Data?", isPresented: $showClearDataConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Everything", role: .destructive) {
                // TODO: clear SwiftData
            }
        } message: {
            Text("This will permanently delete all memories, notes, and photos. This cannot be undone.")
        }
    }

    // MARK: - Helpers

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = DateComponents()
        components.hour = hour
        return formatter.string(from: Calendar.current.date(from: components) ?? Date())
    }

    // MARK: - Reusable Components

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
        .settingsCard()
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
        .settingsCard()
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label { Text(title).font(AppFonts.body).foregroundColor(AppColors.textPrimary) }
                  icon: { Image(systemName: icon).foregroundColor(AppColors.river).frame(width: 20) }
            Spacer()
            Text(value).font(AppFonts.badge).foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .settingsCard()
    }
}

// MARK: - Card Modifier

extension View {
    func settingsCard() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 14).fill(AppColors.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.cardBorder, lineWidth: 1))
        )
    }
}
