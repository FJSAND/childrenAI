import SwiftUI

struct LessonDetailView: View {
    @EnvironmentObject var appState: AppState
    let lesson: Lesson
    @State private var isThinkingExpanded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                // Lesson Info Card
                lessonInfoCard
                // Step 1: Input Instruction
                step1Section
                // Step 2: AI Generates
                step2Section
                // Step 3: Result & Effect
                step3Section
                // Task Checklist
                taskChecklist
                // Pro Tip
                proTipCard
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.top, DS.Spacing.md)
            .padding(.bottom, 120)
        }
        .background(DS.Colors.surface.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Lesson Info Card
extension LessonDetailView {
    private var lessonInfoCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("当前模块")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.8))
                Text(lesson.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, DS.Spacing.sm)
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        Capsule().fill(DS.Colors.tertiaryContainer)
                            .frame(width: geo.size.width * appState.progressPercent, height: 8)
                    }
                }
                .frame(height: 8)
                Text("进度: \(Int(appState.progressPercent * 100))% 完成")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(DS.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Decorative icon
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.12))
                .offset(x: 10, y: -10)
        }
        .background(DS.Colors.primary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .ambientShadow()
    }
}

// MARK: - Step 1: Input Instruction
extension LessonDetailView {
    private var step1Section: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            stepHeader(number: 1, title: "发送指令", color: DS.Colors.primary)
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                Text("向AI机器人发送指令，开始你的创作！")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                // Prompt display + send button
                HStack(spacing: DS.Spacing.sm) {
                    Text(lesson.prompt)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DS.Colors.onSurface)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DS.Spacing.md)
                        .background(DS.Colors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    Button(action: {
                        guard !appState.isLessonStreaming else { return }
                        appState.sendLessonMessage(lesson.prompt)
                    }) {
                        Image(systemName: appState.isLessonStreaming ? "hourglass" : "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(appState.isStep1Done ? DS.Colors.tertiary : DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .disabled(appState.isLessonStreaming)
                }
                if appState.isStep1Done {
                    Label("已发送", systemImage: "checkmark.circle.fill")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(DS.Colors.tertiary)
                }
            }
            .padding(DS.Spacing.md + 2)
            .background(DS.Colors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .ambientShadow()
        }
    }
}


// MARK: - Step 2: AI Generates
extension LessonDetailView {
    /// Latest assistant message from lesson context
    private var latestAssistantMessage: ChatMessage? {
        appState.lessonMessages.last(where: { $0.role == .assistant })
    }
    private var latestAssistantContent: String {
        latestAssistantMessage?.content ?? ""
    }
    private var latestReasoningContent: String {
        latestAssistantMessage?.reasoningContent ?? ""
    }
    /// Whether AI is currently in thinking phase (has reasoning but no content yet)
    private var isThinking: Bool {
        appState.isLessonStreaming && !latestReasoningContent.isEmpty && latestAssistantContent.isEmpty
    }

    private var step2Section: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            stepHeader(number: 2, title: "AI 生成", color: DS.Colors.secondary)

            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                // Status row
                HStack(spacing: DS.Spacing.sm) {
                    if isThinking {
                        ProgressView()
                            .tint(DS.Colors.secondary)
                        Text("AI 正在深度思考...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.Colors.secondary)
                    } else if appState.isLessonStreaming {
                        ProgressView()
                            .tint(DS.Colors.primary)
                        Text("AI 正在生成回答...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.Colors.primary)
                    } else if appState.isStep2Done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(DS.Colors.tertiary)
                        Text("生成完成")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DS.Colors.tertiary)
                    } else {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                        Text("等待发送指令...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                            .italic()
                    }
                    Spacer()
                }

                // Thinking process (reasoning_content)
                if !latestReasoningContent.isEmpty {
                    DisclosureGroup(isExpanded: $isThinkingExpanded) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(latestReasoningContent)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(DS.Colors.secondary.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                                Color.clear.frame(height: 1).id("thinkingBottom")
                            }
                            .frame(maxHeight: 150)
                            .onChange(of: latestReasoningContent, initial: false) {
                                withAnimation { proxy.scrollTo("thinkingBottom", anchor: .bottom) }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("思考过程")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(DS.Colors.secondary)
                    }
                    .padding(DS.Spacing.md)
                    .background(DS.Colors.secondaryContainer.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .onAppear {
                        // Auto-expand when thinking starts
                        if isThinking { isThinkingExpanded = true }
                    }
                    .onChange(of: isThinking, initial: false) {
                        if isThinking { withAnimation { isThinkingExpanded = true } }
                        // Auto-collapse when thinking ends (content starts)
                        if !isThinking && !latestAssistantContent.isEmpty {
                            withAnimation { isThinkingExpanded = false }
                        }
                    }
                }

                // AI response content
                if !latestAssistantContent.isEmpty || (appState.isLessonStreaming && !latestReasoningContent.isEmpty) {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        HStack {
                            Text("AI 回复")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            if appState.isLessonStreaming && !latestAssistantContent.isEmpty {
                                ProgressView().tint(.white.opacity(0.5)).scaleEffect(0.7)
                            }
                        }
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(latestAssistantContent.isEmpty ? "等待思考完成..." : latestAssistantContent)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(latestAssistantContent.isEmpty ? .white.opacity(0.4) : .white.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                                Color.clear.frame(height: 1).id("responseBottom")
                            }
                            .frame(maxHeight: 200)
                            .onChange(of: latestAssistantContent, initial: false) {
                                withAnimation { proxy.scrollTo("responseBottom", anchor: .bottom) }
                            }
                        }
                    }
                    .padding(DS.Spacing.md)
                    .background(DS.Colors.inverseSurface)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
            }
            .padding(DS.Spacing.md + 2)
            .background(DS.Colors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .ambientShadow()
        }
    }
}

// MARK: - Step 3: Result & Effect
extension LessonDetailView {
    /// Whether the AI response contains an HTML code block
    private var responseHasCode: Bool {
        let content = latestAssistantContent
        guard !content.isEmpty else { return false }
        let pattern = "```html\\s*\\n"
        return (try? NSRegularExpression(pattern: pattern))?.firstMatch(
            in: content, range: NSRange(content.startIndex..., in: content)) != nil
    }

    private var step3Section: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            stepHeader(number: 3, title: responseHasCode ? "运行效果" : "完成学习", color: DS.Colors.tertiary)
            VStack(spacing: 0) {
                // Browser chrome bar
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(DS.Colors.error).frame(width: 10, height: 10)
                        Circle().fill(DS.Colors.secondary).frame(width: 10, height: 10)
                        Circle().fill(DS.Colors.tertiary).frame(width: 10, height: 10)
                    }
                    Spacer()
                    if responseHasCode {
                        // Has code — show "运行" button
                        Button(action: {
                            let content = latestAssistantContent
                            let completePattern = "```html\\s*\\n([\\s\\S]*?)```"
                            let unclosedPattern = "```html\\s*\\n([\\s\\S]*)"
                            var extracted: String? = nil
                            if let regex = try? NSRegularExpression(pattern: completePattern),
                               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
                               let range = Range(match.range(at: 1), in: content) {
                                extracted = String(content[range])
                            } else if let regex = try? NSRegularExpression(pattern: unclosedPattern),
                                      let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
                                      let range = Range(match.range(at: 1), in: content) {
                                extracted = String(content[range])
                            }
                            if let code = extracted, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                appState.codeToPreview = code
                                appState.hasRunCode = true
                                // 已完成的课程不再重复奖励积分和勋章
                                let alreadyDone = appState.userStats.completedLessonIds.contains(lesson.id)
                                if !alreadyDone {
                                    appState.recordCodeRun()
                                    appState.markLessonComplete(lesson.id)
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill").font(.system(size: 12))
                                Text("运行").font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(appState.isStep3Done ? DS.Colors.tertiary : DS.Colors.primary)
                            .clipShape(Capsule())
                        }
                    } else {
                        // No code — show "完成课程" button
                        Button(action: {
                            appState.hasRunCode = true
                            // markLessonComplete 内部已有防重复 guard
                            appState.markLessonComplete(lesson.id)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: appState.isStep3Done ? "checkmark.circle.fill" : "flag.fill")
                                    .font(.system(size: 12))
                                Text(appState.isStep3Done ? "已完成" : "完成课程")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.vertical, DS.Spacing.sm)
                            .background(appState.isStep3Done ? DS.Colors.tertiary : DS.Colors.primary)
                            .clipShape(Capsule())
                        }
                        .disabled(appState.isStep3Done || !appState.isStep2Done)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm + 2)
                .background(DS.Colors.surfaceContainer)

                // Preview canvas
                ZStack {
                    Color.white
                    if appState.isStep3Done {
                        VStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 48))
                                .foregroundColor(DS.Colors.tertiary)
                            Text(responseHasCode ? "🎉 运行成功！" : "🎉 课程完成！")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.Colors.onSurface)
                            Text(responseHasCode ? "切换到AI对话页查看完整效果" : "太棒了，继续下一课吧！")
                                .font(.caption)
                                .foregroundColor(DS.Colors.onSurfaceVariant)
                        }
                    } else {
                        VStack(spacing: DS.Spacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(DS.Colors.secondaryContainer)
                                    .frame(width: 80, height: 80)
                                Image(systemName: responseHasCode ? "sparkles" : "book.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(DS.Colors.secondary)
                            }
                            Text(responseHasCode ? "完成前两步后，点击运行查看效果" : "阅读AI回复后，点击完成课程")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DS.Colors.onSurfaceVariant)
                        }
                    }
                }
                .frame(height: 180)
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .ambientShadow()
        }
    }
}

// MARK: - Task Checklist
extension LessonDetailView {
    private var taskChecklist: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md + 2) {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: "checklist")
                    .foregroundColor(DS.Colors.secondary)
                Text("任务清单")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DS.Colors.onSurface)
            }
            checklistRow(done: appState.isStep1Done, title: "Step 1: 发送指令", subtitle: "告诉AI你想做什么")
            checklistRow(done: appState.isStep2Done, title: "Step 2: AI 生成", subtitle: "查看AI的回复")
            checklistRow(done: appState.isStep3Done, title: responseHasCode ? "Step 3: 运行代码" : "Step 3: 完成学习", subtitle: responseHasCode ? "执行代码看效果" : "阅读回复完成课程")
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .stroke(DS.Colors.outlineVariant.opacity(0.1), lineWidth: 1)
        )
        .ambientShadow()
    }

    private func checklistRow(done: Bool, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(done ? DS.Colors.tertiary : Color.clear)
                    .frame(width: 24, height: 24)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(DS.Colors.outlineVariant, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DS.Colors.onSurface.opacity(done ? 1 : 0.5))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.onSurfaceVariant.opacity(done ? 1 : 0.5))
            }
        }
        .opacity(done ? 1 : 0.6)
    }
}

// MARK: - Pro Tip
extension LessonDetailView {
    private var proTipCard: some View {
        HStack(alignment: .top, spacing: DS.Spacing.sm) {
            Rectangle()
                .fill(DS.Colors.tertiary)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("🌟 小提示")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DS.Colors.onTertiaryContainer)
                Text(lesson.goal)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.onTertiaryContainer)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.tertiaryContainer.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
}

// MARK: - Helpers
extension LessonDetailView {
    private func stepHeader(number: Int, title: String, color: Color) -> some View {
        HStack(spacing: DS.Spacing.sm + 2) {
            Text("\(number)")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(color)
                .clipShape(Circle())
            Text("第\(number)步：\(title)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DS.Colors.onSurface)
        }
    }
}

// MARK: - Detail Section (kept for reuse)
struct DetailSection<Content: View>: View {
    let icon: String
    let title: String
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack(spacing: 6) {
                Text(icon)
                Text(title).font(.headline).foregroundColor(accent)
            }
            content
        }
        .padding(DS.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .ambientShadow()
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: CourseData.lowLessons[0])
            .environmentObject(AppState())
    }
}
