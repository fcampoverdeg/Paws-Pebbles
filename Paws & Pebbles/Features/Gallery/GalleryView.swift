import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(sort: \Album.date, order: .reverse) private var albums: [Album]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rock Collections")
                    .font(AppFonts.detailTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 12) {
                        ForEach(Array(albums.enumerated()).filter { $0.offset % 2 == 0 },
                               id: \.element.id) { index, album in
                            albumCard(album: album, height: index == 0 ? 220 : 180)
                        }
                    }
                    VStack(spacing: 12) {
                        Color.clear.frame(height: 20)
                        ForEach(Array(albums.enumerated()).filter { $0.offset % 2 == 1 },
                               id: \.element.id) { _, album in
                            albumCard(album: album, height: 200)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 100)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
    }

    private func albumCard(album: Album, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [Color(hex: album.gradientColor1), Color(hex: album.gradientColor2)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
            VStack {
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .frame(height: height * 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title).font(AppFonts.body).fontWeight(.bold).foregroundColor(.white)
                Text("\(album.mediaFilenames.count) photos").font(AppFonts.badge).foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
        }
        .frame(height: height)
    }
}
