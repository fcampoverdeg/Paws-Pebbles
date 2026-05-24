import SwiftUI
import SwiftData

struct PawMemorialView: View {
    @Query private var puppies: [Puppy]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 40) {
                VStack(spacing: 5) {
                    Text("Always With You")
                        .font(AppFonts.detailTitle)
                        .foregroundColor(AppColors.textPrimary)

                    Text("FOREVER IN OUR HEARTS")
                        .font(AppFonts.subtitle)
                        .tracking(3.5)
                        .foregroundColor(AppColors.textMuted)
                }
                .padding(.top, 80)

                ForEach(Array(puppies.enumerated()), id: \.element.id) { index, puppy in
                    VStack(spacing: 16) {
                        Circle()
                            .fill(AppColors.cardBg)
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(AppColors.river.opacity(0.15), lineWidth: 1.5))
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppColors.river.opacity(0.25))
                            )

                        Text(puppy.name)
                            .font(AppFonts.detailTitle)
                            .foregroundColor(AppColors.textPrimary)

                        if let years = puppy.years {
                            Text(years.uppercased())
                                .font(AppFonts.dateLabel)
                                .tracking(2)
                                .foregroundColor(AppColors.river.opacity(0.5))
                        }

                        Text(puppy.message)
                            .font(AppFonts.bodyLarge)
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 40)
                    }

                    if index < puppies.count - 1 {
                        HStack {
                            Rectangle().fill(AppColors.river.opacity(0.08)).frame(height: 0.5)
                            Image(systemName: "pawprint.fill").font(.system(size: 8)).foregroundColor(AppColors.textDim)
                            Rectangle().fill(AppColors.river.opacity(0.08)).frame(height: 0.5)
                        }
                        .padding(.horizontal, 60)
                    }
                }

                if puppies.isEmpty {
                    VStack(spacing: 24) {
                        puppyPlaceholder(name: "Puppy 1", message: "Forever in our hearts.")
                        puppyPlaceholder(name: "Puppy 2", message: "Always by your side.")
                    }
                }
            }
            .padding(.bottom, 120)
        }
        .hidesTabBarOnScroll()
        .background(AppColors.bgDeep)
    }

    private func puppyPlaceholder(name: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 28))
                .foregroundColor(AppColors.river.opacity(0.2))
            Text(name).font(AppFonts.detailTitle).foregroundColor(AppColors.textPrimary)
            Text(message).font(AppFonts.body).foregroundColor(AppColors.textMuted)
        }
    }
}
