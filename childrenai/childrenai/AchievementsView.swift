import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedWork: SavedWork? = nil



    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    headerSection
                    worksGrid
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.bottom, 40)
            }
            .background(DS.Colors.surface.ignoresSafeArea())

            // Full-screen preview overlay
            if let work = selectedWork {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { selectedWork = nil }

                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                        Text(work.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Button { selectedWork = nil } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.31, green: 0.80, blue: 0.77), Color(red: 0.2, green: 0.6, blue: 0.6)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    WebView(htmlString: work.htmlCode)
                }
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
                .padding(20)
                .transition(.opacity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Header
extension AchievementsView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("你的创意")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(DS.Colors.onSurface)
                Text("乐园")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(DS.Colors.primary)
            }
            .padding(.top, DS.Spacing.sm)

            Text("\(appState.savedWorks.count) 件杰作")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(DS.Colors.onSurface)

            Text("发挥你的奇思妙想，继续创作吧")
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.onSurfaceVariant)
        }
    }
}

// MARK: - Works List
extension AchievementsView {
    private var worksGrid: some View {
        VStack(spacing: DS.Spacing.md) {
            ForEach(appState.savedWorks) { work in
                workCard(work)
            }
            placeholderCard
        }
    }

    private func workCard(_ work: SavedWork) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail or placeholder
            ZStack(alignment: .topTrailing) {
                if let data = work.thumbnailData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 130)
                        .clipped()
                } else {
                    ZStack {
                        LinearGradient(
                            colors: [categoryColor(work.category).opacity(0.08), DS.Colors.surfaceContainer],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        VStack(spacing: 8) {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(categoryColor(work.category).opacity(0.5))
                            Text("点击预览")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(DS.Colors.onSurfaceVariant.opacity(0.6))
                        }
                    }
                    .frame(height: 130)
                }

                // Category badge
                Text(work.category)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.8)
                    .foregroundColor(categoryColor(work.category))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }

            // Info section
            VStack(alignment: .leading, spacing: 6) {
                Text(work.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.onSurface)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(work.createdAt.formatted(.dateTime.locale(Locale(identifier: "zh_CN")).month().day().hour().minute()))
                        .font(.system(size: 12))
                }
                .foregroundColor(DS.Colors.onSurfaceVariant)

                // Open + Delete buttons
                HStack(spacing: 8) {
                    Button {
                        selectedWork = work
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text("打开")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(DS.Colors.onPrimaryContainer)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(DS.Colors.primaryContainer.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            appState.deleteWork(work)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 10))
                            Text("删除")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.sm + 2)
            .padding(.vertical, DS.Spacing.sm + 2)
        }
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .ambientShadow()
    }

    // Placeholder "What will you build next?"
    private var placeholderCard: some View {
        VStack(spacing: DS.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DS.Colors.surfaceVariant)
                    .frame(width: 52, height: 52)
                Image(systemName: "rocket.fill")
                    .font(.system(size: 22))
                    .foregroundColor(DS.Colors.onSurfaceVariant)
            }
            Text("下一个创造什么？")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .stroke(style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
                .foregroundColor(DS.Colors.outlineVariant.opacity(0.4))
        )
        .background(DS.Colors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .onTapGesture { appState.showChatView = true }
    }

    private func categoryColor(_ category: String) -> Color {
        switch category.uppercased() {
        case "ANIMATION": return DS.Colors.primary
        case "LOGIC GAME": return DS.Colors.secondary
        case "AI TOOL": return DS.Colors.tertiary
        default: return DS.Colors.primary
        }
    }
}
