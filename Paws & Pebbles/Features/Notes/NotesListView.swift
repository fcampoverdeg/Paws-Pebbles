import SwiftUI
import SwiftData

struct NotesListView: View {
    @Query(sort: \LoveNote.date, order: .reverse) private var notes: [LoveNote]
    @State private var selectedCategory: NoteCategory?

    private var filteredNotes: [LoveNote] {
        guard let category = selectedCategory else { return notes }
        return notes.filter { $0.category == category }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Engraved Stones")
                    .font(AppFonts.detailTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterPill(title: "All", category: nil)
                        filterPill(title: "Love", category: .love)
                        filterPill(title: "Open when...", category: .openWhen)
                        filterPill(title: "Memories", category: .memory)
                        filterPill(title: "Encouragement", category: .encouragement)
                    }
                    .padding(.horizontal, 20)
                }

                LazyVStack(spacing: 12) {
                    ForEach(filteredNotes) { note in
                        noteCard(note: note)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
    }

    private func filterPill(title: String, category: NoteCategory?) -> some View {
        Button {
            withAnimation(AppAnimations.snappy) { selectedCategory = category }
        } label: {
            Text(title.uppercased())
                .font(AppFonts.button)
                .tracking(1)
                .foregroundColor(selectedCategory == category ? AppColors.river : AppColors.textMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedCategory == category ? AppColors.river.opacity(0.08) : AppColors.cardBg)
                        .overlay(Capsule().stroke(selectedCategory == category ? AppColors.river.opacity(0.15) : AppColors.cardBorder, lineWidth: 1))
                )
        }
    }

    private func noteCard(note: LoveNote) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.category.rawValue.uppercased())
                .font(AppFonts.badge)
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.6))

            if let condition = note.openWhenCondition {
                Text(condition)
                    .font(AppFonts.body)
                    .foregroundColor(.white.opacity(0.8))
            }

            Text(note.message)
                .font(Font.custom("CormorantGaramond-Italic", size: 18))
                .foregroundColor(.white)
                .lineSpacing(4)

            Text(note.date.shortDateString)
                .font(AppFonts.badge)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: gradientColors(for: note.category),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        )
    }

    private func gradientColors(for category: NoteCategory) -> [Color] {
        switch category {
        case .love: return [Color(hex: "#265e46"), Color(hex: "#2e5040")]
        case .openWhen: return [Color(hex: "#163c5a"), Color(hex: "#1a3d58")]
        case .memory: return [Color(hex: "#143328"), Color(hex: "#0c2238")]
        case .encouragement: return [Color(hex: "#2e5040"), Color(hex: "#143328")]
        case .gratitude: return [Color(hex: "#265e46"), Color(hex: "#163c5a")]
        case .justBecause: return [Color(hex: "#2e5040"), Color(hex: "#1a3d58")]
        }
    }
}
