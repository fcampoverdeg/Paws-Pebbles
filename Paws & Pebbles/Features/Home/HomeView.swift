import SwiftUI
import SwiftData
import Combine
import PhotosUI

struct HomeView: View {
    @Query private var notes: [LoveNote]
    @State private var dailyNote: String = ""
    @State private var appeared = false
    @State private var heartPulse = false
    @State private var now = Date()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var homePhoto: UIImage?
    @State private var photoOffset: CGSize = .zero
    @State private var savedOffset: CGSize = .zero
    @State private var photoScale: CGFloat = 1.0
    @State private var savedScale: CGFloat = 1.0
    @State private var showEditor = false
    @AppStorage("parallaxEnabled") private var parallaxEnabled = true
    @StateObject private var parallax = ParallaxMotionManager()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Key dates
    private let togetherSince: Date = {
        var c = DateComponents()
        c.year = 2022; c.month = 6; c.day = 20
        return Calendar.current.date(from: c) ?? Date()
    }()

    private var nextAnniversary: Date {
        let cal = Calendar.current
        var c = DateComponents()
        c.month = 6; c.day = 20
        c.year = cal.component(.year, from: now)
        let thisYear = cal.date(from: c) ?? now
        if thisYear <= now {
            c.year = cal.component(.year, from: now) + 1
        }
        return cal.date(from: c) ?? now
    }

    private var nextBirthday: Date {
        let cal = Calendar.current
        var c = DateComponents()
        c.month = 10; c.day = 21
        c.year = cal.component(.year, from: now)
        let thisYear = cal.date(from: c) ?? now
        if thisYear <= now {
            c.year = cal.component(.year, from: now) + 1
        }
        return cal.date(from: c) ?? now
    }

    private var togetherComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: togetherSince, to: now)
        return (comps.year ?? 0, comps.month ?? 0, comps.day ?? 0,
                comps.hour ?? 0, comps.minute ?? 0, comps.second ?? 0)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroPhoto
                contentBelow
            }
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
        .onReceive(timer) { _ in now = Date() }
        .onAppear {
            dailyNote = getDailyNote()
            loadSavedPhoto()
            if parallaxEnabled { parallax.start() }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) { appeared = true }
            heartPulse = true
        }
        .onDisappear {
            parallax.stop()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            newItem.loadTransferable(type: Data.self) { result in
                if case .success(let data) = result, let data,
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        homePhoto = image
                        photoOffset = .zero
                        savedOffset = .zero
                        photoScale = 1.0
                        savedScale = 1.0
                        savePhoto(image)
                        saveOffset()
                        // Delay so photo picker sheet fully dismisses first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showEditor = true
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let homePhoto {
                PhotoEditorView(
                    image: homePhoto,
                    offset: $photoOffset,
                    savedOffset: $savedOffset,
                    scale: $photoScale,
                    savedScale: $savedScale,
                    onSave: { saveOffset() },
                    onCancel: {
                        photoOffset = savedOffset
                        photoScale = savedScale
                    }
                )
            }
        }
    }

    // MARK: - Hero Photo Section

    private let screenH = UIScreen.main.bounds.height

    private var heroPhoto: some View {
        ZStack {
            // Photo fills the entire first screen — 3D parallax
            if let homePhoto {
                GeometryReader { geo in
                    Image(uiImage: homePhoto)
                        .resizable()
                        .scaledToFill()
                        // Slightly overscale so parallax shift doesn't reveal edges
                        .scaleEffect(photoScale * (parallaxEnabled ? 1.08 : 1.0))
                        .offset(
                            x: photoOffset.width + (parallaxEnabled ? parallax.xOffset : 0),
                            y: photoOffset.height + (parallaxEnabled ? parallax.yOffset : 0)
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.river.opacity(0.08),
                                AppColors.cardBg,
                                AppColors.river.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 44))
                                .foregroundColor(AppColors.river.opacity(0.12))
                                .scaleEffect(heartPulse ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: heartPulse)

                            Text("Tap the pencil to add your photo")
                                .font(AppFonts.badge)
                                .foregroundColor(AppColors.textDim)
                        }
                        .offset(y: -100)
                    )
            }

            // Edit button — top right corner
            VStack {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(AppColors.river)
                            )
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 12)
                Spacer()
            }

            // Gradient fade at bottom
            VStack {
                Spacer()
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: AppColors.bgDeep.opacity(0.8), location: 0.5),
                        .init(color: AppColors.bgDeep, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }

            // Bottom-anchored: title + pebble card
            // Card grows upward, bottom stays fixed
            VStack(spacing: 12) {
                Spacer()

                HStack(spacing: 0) {
                    Text("Sebi ")
                        .font(Font.custom("CormorantGaramond-Light", size: 42))
                        .foregroundColor(.white)
                    Text("&")
                        .font(Font.custom("CormorantGaramond-Italic", size: 42))
                        .foregroundColor(AppColors.river)
                    Text(" Natty")
                        .font(Font.custom("CormorantGaramond-Light", size: 42))
                        .foregroundColor(.white)
                }

                Text("OUR STORY, ONE PEBBLE AT A TIME")
                    .font(AppFonts.subtitle)
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.6))

                dailyPebbleCard
                    .padding(.top, 4)
            }
            .shadow(color: .black.opacity(0.5), radius: 8, y: 2)
            .padding(.bottom, 180)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .frame(height: screenH)
    }

    // MARK: - Content Below (revealed on scroll)

    private var contentBelow: some View {
        VStack(spacing: 20) {
            // Timer rises up with 3D tilt
            ScrollReveal(delay: 0, direction: .bottom) {
                togetherTimer
            }
            .padding(.top, 4)

            // Stats grid — each card from alternating sides
            statsGridAnimated

            // Upcoming slides up
            ScrollReveal(delay: 0, direction: .bottom) {
                upcomingSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }

    private var statsGridAnimated: some View {
        let daysToAnniversary = Calendar.current.dateComponents([.day], from: now, to: nextAnniversary).day ?? 0
        let daysToBirthday = Calendar.current.dateComponents([.day], from: now, to: nextBirthday).day ?? 0
        let yearsCount = Calendar.current.dateComponents([.year], from: togetherSince, to: now).year ?? 0

        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ScrollReveal(delay: 0, direction: .left) {
                statCard(emoji: "💕", title: "Anniversary", value: "\(daysToAnniversary)",
                        subtitle: "days away", detail: "June 20", accent: AppColors.river)
            }
            ScrollReveal(delay: 0.06, direction: .right) {
                statCard(emoji: "🎂", title: "Natty's Birthday", value: "\(daysToBirthday)",
                        subtitle: "days away", detail: "October 21", accent: AppColors.roseQuartz)
            }
            ScrollReveal(delay: 0.12, direction: .left) {
                statCard(emoji: "🪨", title: "Years Together", value: "\(yearsCount)",
                        subtitle: yearsCount == 1 ? "year" : "years", detail: "Since 2022", accent: AppColors.sandstone)
            }
            ScrollReveal(delay: 0.18, direction: .right) {
                statCard(emoji: "✨", title: "Total Days", value: "\(togetherSince.daysSince)",
                        subtitle: "days of us", detail: "and counting", accent: AppColors.gold)
            }
        }
    }

    // MARK: - Together Timer (live)

    private var togetherTimer: some View {
        let t = togetherComponents

        return VStack(spacing: 10) {
            Text("TOGETHER FOR")
                .font(AppFonts.badge)
                .tracking(2.5)
                .foregroundColor(AppColors.textMuted)

            HStack(spacing: 4) {
                timerUnit(value: t.years, label: "YRS")
                timerSeparator
                timerUnit(value: t.months, label: "MO")
                timerSeparator
                timerUnit(value: t.days, label: "DAYS")
                timerSeparator
                timerUnit(value: t.hours, label: "HRS")
                timerSeparator
                timerUnit(value: t.minutes, label: "MIN")
                timerSeparator
                timerUnit(value: t.seconds, label: "SEC")
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppColors.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppColors.river.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func timerUnit(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(Font.custom("CormorantGaramond-Medium", size: 28))
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 7, weight: .medium))
                .tracking(1)
                .foregroundColor(AppColors.textDim)
        }
        .frame(minWidth: 36)
    }

    private var timerSeparator: some View {
        Text(":")
            .font(Font.custom("CormorantGaramond-Light", size: 22))
            .foregroundColor(AppColors.river.opacity(0.3))
            .offset(y: -4)
    }

    private func statCard(emoji: String, title: String, value: String, subtitle: String, detail: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(emoji).font(.system(size: 22))
                Spacer()
                Text(detail)
                    .font(.system(size: 8, weight: .medium))
                    .tracking(1)
                    .foregroundColor(accent.opacity(0.6))
                    .textCase(.uppercase)
            }

            Text(value)
                .font(Font.custom("CormorantGaramond-Medium", size: 36))
                .foregroundColor(AppColors.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text(subtitle)
                .font(AppFonts.badge)
                .foregroundColor(AppColors.textMuted)

            Text(title)
                .font(AppFonts.body)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Daily Pebble Card

    private var dailyPebbleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle().fill(AppColors.river).frame(width: 6, height: 6)
                Text("TODAY'S PEBBLE")
                    .font(AppFonts.badge)
                    .tracking(1.5)
                    .foregroundColor(AppColors.textMuted)
            }

            Text(dailyNote)
                .font(Font.custom("CormorantGaramond-Italic", size: 20))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(8)

            HStack {
                Spacer()
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.river.opacity(0.15))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppColors.cardBg.opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppColors.cardBorder, lineWidth: 1))
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        let events = upcomingEvents()

        return VStack(alignment: .leading, spacing: 12) {
            if !events.isEmpty {
                Text("COMING UP")
                    .font(AppFonts.badge)
                    .tracking(2)
                    .foregroundColor(AppColors.textDim)
                    .padding(.leading, 4)

                ForEach(events, id: \.title) { event in
                    HStack(spacing: 14) {
                        Text(event.emoji)
                            .font(.system(size: 24))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle().fill(AppColors.river.opacity(0.06))
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(event.title)
                                .font(AppFonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                            Text(event.dateString)
                                .font(AppFonts.badge)
                                .foregroundColor(AppColors.textMuted)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(event.daysUntil)")
                                .font(Font.custom("CormorantGaramond-Medium", size: 24))
                                .foregroundColor(AppColors.river)
                            Text("days")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(AppColors.textDim)
                                .textCase(.uppercase)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.cardBg)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.cardBorder, lineWidth: 1))
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private struct UpcomingEvent {
        let emoji: String
        let title: String
        let dateString: String
        let daysUntil: Int
    }

    private func upcomingEvents() -> [UpcomingEvent] {
        let cal = Calendar.current
        let annDays = cal.dateComponents([.day], from: now, to: nextAnniversary).day ?? 0
        let bdayDays = cal.dateComponents([.day], from: now, to: nextBirthday).day ?? 0

        var events = [
            UpcomingEvent(emoji: "💕", title: "Our Anniversary", dateString: "June 20", daysUntil: annDays),
            UpcomingEvent(emoji: "🎂", title: "Natty's Birthday", dateString: "October 21", daysUntil: bdayDays)
        ]
        events.sort { $0.daysUntil < $1.daysUntil }
        return events
    }

    private func getDailyNote() -> String {
        let allMessages = notes.map(\.message) + [
            "Every moment with you is a pebble I treasure.",
            "Like the rocks you study, my love for you is ancient and enduring.",
            "You make ordinary moments extraordinary.",
            "You're my favorite hello and my hardest goodbye.",
            "Some people search their whole lives for what we have.",
            "You're the reason I believe in forever.",
            "Every day with you is my new favorite day.",
            "I fell in love with your laugh before anything else.",
            "You turn ordinary days into memories I never want to forget."
        ]

        guard !allMessages.isEmpty else { return "You are loved." }

        let todayKey = todayString()
        if let savedDate = UserDefaults.standard.string(forKey: "dailyPebble_date"),
           savedDate == todayKey,
           let savedNote = UserDefaults.standard.string(forKey: "dailyPebble_note") {
            return savedNote
        }

        let daysSinceEpoch = Calendar.current.dateComponents([.day],
            from: Date(timeIntervalSince1970: 0), to: Date()).day ?? 0
        let index = daysSinceEpoch % allMessages.count
        let note = allMessages[index]

        UserDefaults.standard.set(todayKey, forKey: "dailyPebble_date")
        UserDefaults.standard.set(note, forKey: "dailyPebble_note")

        return note
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // MARK: - Photo Persistence

    private var photoURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("home_photo.jpg")
    }

    private func savePhoto(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: photoURL)
        }
    }

    private func loadSavedPhoto() {
        if let data = try? Data(contentsOf: photoURL),
           let image = UIImage(data: data) {
            homePhoto = image
            loadOffset()
        }
    }

    private func saveOffset() {
        UserDefaults.standard.set(Double(photoOffset.width), forKey: "homePhoto_offsetX")
        UserDefaults.standard.set(Double(photoOffset.height), forKey: "homePhoto_offsetY")
        UserDefaults.standard.set(Double(photoScale), forKey: "homePhoto_scale")
    }

    private func loadOffset() {
        let x = UserDefaults.standard.double(forKey: "homePhoto_offsetX")
        let y = UserDefaults.standard.double(forKey: "homePhoto_offsetY")
        let s = UserDefaults.standard.double(forKey: "homePhoto_scale")

        // Sanity check — reset if values are crazy from a previous bug
        if abs(x) > 300 || abs(y) > 300 || s > 3 || (s > 0 && s < 0.5) {
            photoOffset = .zero
            savedOffset = .zero
            photoScale = 1.0
            savedScale = 1.0
            saveOffset()
            return
        }

        photoOffset = CGSize(width: x, height: y)
        savedOffset = photoOffset
        photoScale = s > 0 ? s : 1.0
        savedScale = photoScale
    }

    private func resetPhotoPosition() {
        photoOffset = .zero
        savedOffset = .zero
        photoScale = 1.0
        savedScale = 1.0
        saveOffset()
    }
}

// MARK: - Scroll Reveal Animation

struct ScrollReveal<Content: View>: View {
    let delay: Double
    var direction: RevealDirection = .bottom
    @ViewBuilder let content: () -> Content

    @State private var isVisible = false
    @State private var progress: CGFloat = 0

    enum RevealDirection {
        case bottom, left, right, scale
    }

    var body: some View {
        content()
            .opacity(isVisible ? 1 : 0)
            .offset(
                x: offsetX,
                y: offsetY
            )
            .scaleEffect(scaleValue)
            .rotation3DEffect(
                .degrees(isVisible ? 0 : rotationDegrees),
                axis: rotationAxis,
                perspective: 0.4
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, minY in
                            let screenH = UIScreen.main.bounds.height
                            if minY < screenH * 0.92 && !isVisible {
                                withAnimation(
                                    .spring(response: 0.7, dampingFraction: 0.68)
                                    .delay(delay)
                                ) {
                                    isVisible = true
                                }
                            }
                        }
                }
            )
    }

    private var offsetX: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .left: return -60
        case .right: return 60
        default: return 0
        }
    }

    private var offsetY: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .bottom: return 50
        case .scale: return 20
        default: return 15
        }
    }

    private var scaleValue: CGFloat {
        guard !isVisible else { return 1 }
        switch direction {
        case .scale: return 0.8
        default: return 0.97
        }
    }

    private var rotationDegrees: Double {
        switch direction {
        case .bottom: return 6
        case .left: return -4
        case .right: return 4
        case .scale: return 0
        }
    }

    private var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch direction {
        case .bottom: return (1, 0, 0)
        case .left, .right: return (0, 1, 0)
        case .scale: return (0, 0, 1)
        }
    }
}
