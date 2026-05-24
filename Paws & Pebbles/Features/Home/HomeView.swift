import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Memory.sortOrder) private var memories: [Memory]
    @Query private var notes: [LoveNote]
    @Query private var albums: [Album]
    @State private var dailyNote: String = ""
    @State private var appeared = false
    @State private var heartPulse = false

    private let togetherSince: Date = {
        var components = DateComponents()
        components.year = 2022
        components.month = 6
        components.day = 20
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroSection
                dailyPebbleCard
                navigationGrid
            }
            .padding(.bottom, 100)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
        .onAppear {
            dailyNote = randomDailyNote()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) { appeared = true }
            heartPulse = true
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [AppColors.river.opacity(0.08), .clear],
                          center: .center, startRadius: 40, endRadius: 80))
                    .frame(width: 160, height: 160)
                    .scaleEffect(heartPulse ? 1.1 : 0.95)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: heartPulse)

                Circle()
                    .fill(AppColors.cardBg)
                    .frame(width: 120, height: 120)
                    .overlay(Circle().stroke(AppColors.river.opacity(0.2), lineWidth: 2.5))
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.river.opacity(0.25))
                    )
                    .scaleEffect(appeared ? 1 : 0.5)
                    .opacity(appeared ? 1 : 0)
            }

            Text("S & Natty")
                .font(AppFonts.detailTitle)
                .foregroundColor(AppColors.textPrimary)
                .opacity(appeared ? 1 : 0)

            Text("Together since Jun 20, 2022 — \(togetherSince.daysSince) days")
                .font(AppFonts.badge)
                .foregroundColor(AppColors.textMuted)
                .opacity(appeared ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [AppColors.river.opacity(0.05), AppColors.bgDeep],
                          startPoint: .top, endPoint: .bottom)
        )
    }

    private var dailyPebbleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(AppColors.river).frame(width: 6, height: 6)
                Text("TODAY'S PEBBLE")
                    .font(AppFonts.badge)
                    .tracking(1.5)
                    .foregroundColor(AppColors.textMuted)
            }
            Text(dailyNote)
                .font(Font.custom("CormorantGaramond-Italic", size: 18))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppColors.cardBorder, lineWidth: 1))
        )
        .padding(.horizontal, 20)
    }

    private var navigationGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            navCard(icon: "circle.circle", title: "Timeline", subtitle: "\(memories.count) memories")
            navCard(icon: "photo.on.rectangle", title: "Gallery", subtitle: "\(albums.count) collections")
            navCard(icon: "heart.fill", title: "Love Notes", subtitle: "\(notes.count) stones")
            navCard(icon: "star.fill", title: "Surprises", subtitle: "3 geodes")
        }
        .padding(.horizontal, 20)
    }

    private func navCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(AppColors.river.opacity(0.08)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(AppColors.river)
            }
            Text(title).font(AppFonts.body).fontWeight(.medium).foregroundColor(AppColors.textPrimary)
            Text(subtitle).font(AppFonts.badge).foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppColors.cardBorder, lineWidth: 1))
        )
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appeared)
    }

    private func randomDailyNote() -> String {
        let defaults = [
            "Every moment with you is a pebble I treasure.",
            "Like the rocks you study, my love for you is ancient and enduring.",
            "You make ordinary moments extraordinary.",
            "You're my favorite hello and my hardest goodbye."
        ]
        if let note = notes.randomElement() { return note.message }
        return defaults.randomElement() ?? defaults[0]
    }
}
