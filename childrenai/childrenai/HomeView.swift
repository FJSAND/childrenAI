import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Spacing.lg) {
                greetingHeader
                heroSection
                bentoGrid
                gradeLevelSection
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.top, DS.Spacing.sm)
            .padding(.bottom, 100)
        }
        .background(DS.Colors.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Greeting Header
    private var greetingHeader: some View {
        HStack(spacing: 12) {
            // Avatar — tap to go to Profile
            ZStack {
                Circle()
                    .fill(DS.Colors.primaryContainer)
                    .frame(width: 48, height: 48)
                    .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, y: 4)
                    .overlay(
                        Text("🧑‍🚀").font(.system(size: 26))
                    )
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
            }
            .onTapGesture { appState.selectedTab = 3 }
            VStack(alignment: .leading, spacing: 2) {
                Text("Hi, 小探险家!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(DS.Colors.primary)
                Text("准备好AI冒险了吗？")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DS.Colors.onBackground.opacity(0.7))
            }
            Spacer()
            // Points badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                Text("\(appState.userStats.points) 积分")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(DS.Colors.onSecondaryContainer)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(DS.Colors.secondaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(DS.Colors.surfaceContainer)

            // Decorative blurs
            Circle().fill(DS.Colors.primaryContainer.opacity(0.2))
                .frame(width: 180).blur(radius: 50)
                .offset(x: 150, y: -60)
            Circle().fill(DS.Colors.tertiaryContainer.opacity(0.2))
                .frame(width: 130).blur(radius: 40)
                .offset(x: -50, y: 100)

            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                // TODAY'S QUEST badge
                Text("今日任务")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(DS.Colors.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(DS.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())

                // Main title
                (Text("今天我们")
                    .foregroundColor(DS.Colors.onBackground)
                + Text("编")
                    .foregroundColor(DS.Colors.primary)
                + Text("什么？")
                    .foregroundColor(DS.Colors.onBackground))
                    .font(.system(size: 30, weight: .heavy))
                    .lineSpacing(2)

                Text("AI的世界就是你的游乐场！选择你的等级，开始编程吧。")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                    .lineSpacing(3)

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: { appState.selectedTab = 1 }) {
                        Text("开始旅程")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                            .shadow(color: DS.Colors.primaryDim, radius: 0, y: 6)
                    }

                    Button(action: { appState.selectedTab = 1 }) {
                        Text("查看地图")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.Colors.primary)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(DS.Colors.surfaceContainerLowest)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.md)
                                    .stroke(DS.Colors.primary.opacity(0.1), lineWidth: 2)
                            )
                    }
                }
            }
            .padding(DS.Spacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }

    // MARK: - Bento Grid (Progress + New Lesson)
    private var bentoGrid: some View {
        VStack(spacing: DS.Spacing.md) {
            // Weekly Mastery Card
            weeklyMasteryCard
            // New Lesson Card
            newLessonCard
        }
    }

    // MARK: - 成长等级称号（按勋章数）
    private var masteryTitle: String {
        let count = appState.userStats.unlockedBadgeIds.count
        switch count {
        case 0:       return "小萌新"
        case 1...2:   return "小探险家"
        case 3...4:   return "小学者"
        case 5...6:   return "小达人"
        case 7...9:   return "小专家"
        case 10...12: return "小大师"
        default:      return "编程小天才"
        }
    }

    private var masteryIcon: String {
        let count = appState.userStats.unlockedBadgeIds.count
        switch count {
        case 0:       return "🌱"
        case 1...2:   return "🧭"
        case 3...4:   return "📖"
        case 5...6:   return "⭐"
        case 7...9:   return "🏅"
        case 10...12: return "👑"
        default:      return "🚀"
        }
    }

    // 综合进度：课程完成 70% + 勋章获得 30%
    private var overallProgress: Double {
        let totalLessons = Double(CourseData.lowLessons.count + CourseData.midLessons.count + CourseData.highLessons.count)
        let totalBadges = Double(AppState.allBadges.count)
        let lessonRatio = totalLessons > 0 ? Double(appState.userStats.completedLessonIds.count) / totalLessons : 0
        let badgeRatio = totalBadges > 0 ? Double(appState.userStats.unlockedBadgeIds.count) / totalBadges : 0
        return min((lessonRatio * 0.7 + badgeRatio * 0.3), 1.0)
    }

    private var weeklyMasteryCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("我已精通")
                        .font(.system(size: 20, weight: .bold))
                    Text("我已达到了「\(masteryTitle)」")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                }
                Spacer()
            }

            // Progress bar
            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(DS.Colors.surfaceContainer).frame(height: 12)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [DS.Colors.primary, DS.Colors.primaryContainer],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * CGFloat(overallProgress), height: 12)
                    }
                }.frame(height: 12)
                Text("\(Int(overallProgress * 100))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(DS.Colors.primary)
            }

            // Stats grid
            HStack(spacing: 10) {
                StatBox(value: "\(appState.userStats.completedLessonIds.count)", label: "课时")
                StatBox(value: "\(appState.userStats.unlockedBadgeIds.count)", label: "徽章")
                StatBox(value: "\(appState.userStats.points)", label: "积分")
                StatBox(value: "\(appState.userStats.totalLogins)", label: "打卡")
            }
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .ambientShadow()
    }

    private var newLessonCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(DS.Colors.inverseSurface)

            // Abstract glow
            Circle()
                .fill(DS.Colors.primaryContainer.opacity(0.3))
                .frame(width: 120)
                .blur(radius: 40)
                .offset(x: 40, y: 80)

            // Background icon
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 56))
                .foregroundColor(.white.opacity(0.08))
                .rotationEffect(.degrees(12))
                .offset(x: -8, y: 8)

            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("新课程")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DS.Colors.onTertiaryContainer)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(DS.Colors.tertiaryContainer)
                    .clipShape(Capsule())

                Text("魔法画室")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("学习如何向AI描述颜色来画画。")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))

                Spacer().frame(height: 4)

                Button(action: { appState.showChatView = true }) {
                    Text("立即尝试")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(DS.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }

    // MARK: - Grade Level Section
    private var gradeLevelSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DS.Colors.primary)
                Text("选择你的等级")
                    .font(.system(size: 22, weight: .bold))
            }

            ForEach(Level.allCases) { level in
                GradeLevelCard(level: level)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            appState.currentLevel = level
                            appState.selectedTab = 1
                        }
                    }
            }
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(DS.Colors.onBackground)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1.2)
                .foregroundColor(DS.Colors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(DS.Colors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }
}

// MARK: - Grade Level Card (Vertical Layout)
struct GradeLevelCard: View {
    let level: Level

    private var accentColor: Color {
        switch level {
        case .low: return DS.Colors.primary
        case .mid: return DS.Colors.secondary
        case .high: return DS.Colors.tertiary
        }
    }

    private var containerColor: Color {
        switch level {
        case .low: return DS.Colors.primaryContainer
        case .mid: return DS.Colors.secondaryContainer
        case .high: return DS.Colors.tertiaryContainer
        }
    }

    private var iconName: String {
        switch level {
        case .low: return "face.smiling.inverse"
        case .mid: return "square.and.pencil"
        case .high: return "lightbulb.fill"
        }
    }

    private var englishTitle: String {
        switch level {
        case .low: return "AI听我说！"
        case .mid: return "项目实战！"
        case .high: return "提示词工程！"
        }
    }

    private var chineseSubtitle: String {
        switch level {
        case .low: return "认识文字指令"
        case .mid: return "用文字做项目"
        case .high: return "提示词工程进阶"
        }
    }

    private var subtitleIcon: String {
        switch level {
        case .low: return "pencil.line"
        case .mid: return "rocket.fill"
        case .high: return "terminal.fill"
        }
    }

    private var description: String {
        switch level {
        case .low: return "用简单的文字和机器人对话！学习AI如何理解你的声音和文字来画画或讲故事。"
        case .mid: return "开始创造！用提示词来制作你自己的游戏、数字日记和学校演示文稿。"
        case .high: return "掌握幕后逻辑。学习复杂的提示词结构，实现专业级的AI创作效果。"
        }
    }

    private var lessonCount: String {
        switch level {
        case .low: return "8 课时"
        case .mid: return "12 课时"
        case .high: return "15 课时"
        }
    }

    private var onAccentColor: Color {
        switch level {
        case .low: return .white
        case .mid: return DS.Colors.onSecondary
        case .high: return .white
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon box
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(containerColor.opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: iconName)
                    .font(.system(size: 28))
                    .foregroundColor(accentColor)
            }
            .padding(.bottom, DS.Spacing.md)

            // Level label
            Text(level.name)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(accentColor)
                .textCase(.uppercase)
                .padding(.bottom, 6)

            // English title
            Text(englishTitle)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(DS.Colors.onBackground)
                .padding(.bottom, 10)

            // Chinese subtitle tag
            HStack(spacing: 6) {
                Image(systemName: subtitleIcon)
                    .font(.system(size: 12))
                Text(chineseSubtitle)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(DS.Colors.onSurface)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .padding(.bottom, DS.Spacing.md)

            // Description
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .lineSpacing(4)
                .padding(.bottom, DS.Spacing.lg)

            // Footer
            HStack {
                Text(lessonCount)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                Spacer()
                ZStack {
                    Circle().fill(accentColor).frame(width: 44, height: 44)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(onAccentColor)
                }
            }
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .ambientShadow()
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
