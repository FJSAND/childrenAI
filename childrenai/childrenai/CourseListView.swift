import SwiftUI

struct CourseListView: View {
    @EnvironmentObject var appState: AppState

    private var accentColor: Color {
        switch appState.currentLevel {
        case .low: return DS.Colors.primary
        case .mid: return DS.Colors.secondary
        case .high: return DS.Colors.tertiary
        }
    }

    private var containerColor: Color {
        switch appState.currentLevel {
        case .low: return DS.Colors.primaryContainer
        case .mid: return DS.Colors.secondaryContainer
        case .high: return DS.Colors.tertiaryContainer
        }
    }

    private var levelTitle: String {
        switch appState.currentLevel {
        case .low: return "低段\n编程之旅"
        case .mid: return "中段\n编程之旅"
        case .high: return "高段\n编程之旅"
        }
    }

    private var levelDesc: String {
        switch appState.currentLevel {
        case .low: return "用简单文字和机器人对话！学习AI如何理解你的指令。(1-2年级启蒙篇)"
        case .mid: return "开始你的文字编程冒险，创造属于自己的数字世界！(3-4年级实战篇)"
        case .high: return "掌握提示词工程，成为AI项目设计师！(5-6年级进阶篇)"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Spacing.lg) {
                heroBanner
                levelPicker
                lessonListSection
                progressBento
            }
            .padding(.bottom, 100)
        }
        .background(DS.Colors.surface.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Hero Banner
    private var heroBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(
                    LinearGradient(
                        colors: [accentColor, containerColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Decorative orbs
            Circle().fill(.white.opacity(0.12))
                .frame(width: 140).offset(x: 120, y: -50)
            Circle().fill(.white.opacity(0.08))
                .frame(width: 100).offset(x: -80, y: 60)

            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    // Current Path badge
                    Text("当前路径")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.3))
                        .clipShape(Capsule())

                    Text(levelTitle)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(.white)
                        .lineSpacing(2)

                    Text(levelDesc)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(DS.Colors.onPrimaryContainer)
                        .opacity(0.9)
                        .lineSpacing(2)
                }
                .padding(DS.Spacing.lg)

                Spacer()

                // Placeholder illustration area
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 90)
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.trailing, DS.Spacing.md)
            }
        }
        .frame(minHeight: 190)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.sm)
    }

    // MARK: - Level Picker
    private var levelPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(Level.allCases) { level in
                    LevelTab(level: level, isSelected: appState.currentLevel == level)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                appState.currentLevel = level
                            }
                        }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Lesson List
    private var lessonListSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 18))
                    .foregroundColor(DS.Colors.primary)
                Text("课程大纲")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(DS.Colors.onSurface)
            }
            .padding(.horizontal, DS.Spacing.lg)

            let lessons = CourseData.lessons(for: appState.currentLevel)
            LazyVStack(spacing: DS.Spacing.md) {
                ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                    let status = appState.lessonStatus(for: lesson.id, in: appState.currentLevel)
                    if status != .locked {
                        NavigationLink(destination: LessonDetailView(lesson: lesson)
                            .onAppear {
                                appState.selectedLesson = lesson
                                appState.markLessonStarted(lesson.id)
                            }
                        ) {
                            LessonCard(
                                lesson: lesson,
                                index: index + 1,
                                status: status,
                                accentColor: accentColor
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        LessonCard(
                            lesson: lesson,
                            index: index + 1,
                            status: status,
                            accentColor: accentColor
                        )
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }




    // MARK: - Progress Bento Cards
    private var progressBento: some View {
        VStack(spacing: DS.Spacing.md) {
            // Weekly Goal
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("每周目标")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(DS.Colors.onSecondaryContainer)
                HStack(alignment: .bottom) {
                    Text("2/5")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(DS.Colors.secondary)
                    Spacer()
                    Text("已完成课时")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(DS.Colors.secondary.opacity(0.7))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.5)).frame(height: 10)
                        Capsule().fill(DS.Colors.secondary)
                            .frame(width: geo.size.width * 0.4, height: 10)
                    }
                }.frame(height: 10)
            }
            .padding(DS.Spacing.lg)
            .background(DS.Colors.secondaryContainer.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.secondaryContainer.opacity(0.2), lineWidth: 2)
            )

            // Next Milestone
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("下一个里程碑")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(DS.Colors.onTertiaryContainer)
                    Text("完成「第一个动画」课程，解锁创意工作室！")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.onTertiaryContainer.opacity(0.8))
                        .lineSpacing(3)
                    HStack(spacing: 8) {
                        milestoneIcon("trophy.fill")
                        milestoneIcon("paintpalette.fill")
                    }
                    .padding(.top, 4)
                }
                .padding(DS.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60))
                    .foregroundColor(DS.Colors.tertiary.opacity(0.05))
                    .offset(x: -8, y: -8)
            }
            .background(DS.Colors.tertiaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.tertiaryContainer.opacity(0.2), lineWidth: 2)
            )
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func milestoneIcon(_ name: String) -> some View {
        ZStack {
            Circle().fill(.white.opacity(0.4)).frame(width: 32, height: 32)
            Image(systemName: name)
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.tertiary)
        }
    }
}

// MARK: - Lesson Status
enum LessonStatus {
    case completed, inProgress, notStarted, locked
}

// MARK: - Level Tab
struct LevelTab: View {
    let level: Level
    let isSelected: Bool

    private var color: Color {
        switch level {
        case .low: return DS.Colors.primary
        case .mid: return DS.Colors.secondary
        case .high: return DS.Colors.tertiary
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(level.icon).font(.callout)
            Text(level.name)
                .font(.system(size: 13, weight: .bold))
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, 10)
        .background(isSelected ? color : DS.Colors.surfaceContainerLow)
        .foregroundColor(isSelected ? .white : DS.Colors.onSurfaceVariant)
        .clipShape(Capsule())
    }
}

// MARK: - Lesson Card (3 States)
struct LessonCard: View {
    let lesson: Lesson
    let index: Int
    let status: LessonStatus
    let accentColor: Color

    private var iconBgColor: Color {
        switch status {
        case .completed: return DS.Colors.tertiaryContainer
        case .inProgress: return DS.Colors.primaryContainer
        case .notStarted: return DS.Colors.secondaryContainer
        case .locked: return DS.Colors.surfaceContainerHighest
        }
    }

    private var iconFgColor: Color {
        switch status {
        case .completed: return DS.Colors.onTertiaryContainer
        case .inProgress: return .white
        case .notStarted: return DS.Colors.secondary
        case .locked: return DS.Colors.outline
        }
    }

    private var lessonIcon: String {
        if lesson.isTask { return "flag.fill" }
        switch status {
        case .completed: return "terminal.fill"
        case .inProgress: return "sparkles"
        case .notStarted: return "play.fill"
        case .locked: return "bolt.fill"
        }
    }

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Circular icon
            ZStack {
                Circle()
                    .fill(iconBgColor)
                    .frame(width: 52, height: 52)
                Image(systemName: lessonIcon)
                    .font(.system(size: 20))
                    .foregroundColor(iconFgColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("第 \(index) 课")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(statusLabelColor)
                Text(lesson.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.Colors.onSurface.opacity(status == .locked ? 0.5 : 1))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            statusBadge
        }
        .padding(DS.Spacing.md + 2)
        .background(status == .locked ? DS.Colors.surfaceContainer : DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            status == .inProgress
                ? RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(DS.Colors.primary.opacity(0.2), lineWidth: 2)
                : nil
        )
        .ambientShadow()
    }

    private var statusLabelColor: Color {
        switch status {
        case .completed: return DS.Colors.tertiary
        case .inProgress: return DS.Colors.primary
        case .notStarted: return DS.Colors.secondary
        case .locked: return DS.Colors.onSurfaceVariant
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))
                Text("已完成")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(DS.Colors.tertiary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DS.Colors.tertiaryContainer.opacity(0.3))
            .clipShape(Capsule())

        case .inProgress:
            HStack(spacing: 4) {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .font(.system(size: 11))
                Text("进行中")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(DS.Colors.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DS.Colors.primaryContainer.opacity(0.2))
            .clipShape(Capsule())

        case .notStarted:
            HStack(spacing: 4) {
                Image(systemName: "circle")
                    .font(.system(size: 11))
                Text("待开始")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(DS.Colors.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DS.Colors.secondaryContainer.opacity(0.3))
            .clipShape(Capsule())

        case .locked:
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                Text("未解锁")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(DS.Colors.onSurfaceVariant)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DS.Colors.surfaceVariant)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    CourseListView()
        .environmentObject(AppState())
}