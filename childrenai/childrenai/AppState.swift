import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var currentLevel: Level = .low
    @Published var selectedLesson: Lesson? = nil
    // Chat tab messages (independent)
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatHistory: [[String: String]] = []
    @Published var isStreaming: Bool = false
    // Lesson detail page messages (independent)
    @Published var lessonMessages: [ChatMessage] = []
    @Published var lessonChatHistory: [[String: String]] = []
    @Published var isLessonStreaming: Bool = false

    @Published var apiKey: String = ""
    @Published var showApiKeySheet: Bool = false

    // AI 隐私同意
    @Published var hasAgreedAIConsent: Bool = false
    @Published var showAIConsentDialog: Bool = false
    var pendingAIMessage: String? = nil
    var pendingIsLesson: Bool = false
    @Published var selectedTab: Int = 0
    @Published var homePath = NavigationPath()
    @Published var achievementsPath = NavigationPath()
    var showChatView: Bool {
        get { return false }
        set {
            if newValue {
                // Push chat onto the current tab's navigation stack
                if selectedTab == 0 {
                    homePath.append("chat")
                } else if selectedTab == 2 {
                    achievementsPath.append("chat")
                } else {
                    // Default: switch to home tab and push
                    selectedTab = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.homePath.append("chat")
                    }
                }
            }
        }
    }
    @Published var codeToPreview: String? = nil
    @Published var hasRunCode: Bool = false
    @Published var savedWorks: [SavedWork] = []

    // MARK: - 勋章解锁动画
    @Published var newlyUnlockedBadge: BadgeDefinition? = nil

    // MARK: - 用户进度数据
    @Published var userStats = UserStats()

    // MARK: - 13 枚徽章定义
    static let allBadges: [BadgeDefinition] = [
        BadgeDefinition(id: 1,  imageName: "medal_001", title: "初学者",     description: "完成第一节课程",       conditionType: .completeFirstLesson, threshold: 1),
        BadgeDefinition(id: 2,  imageName: "medal_002", title: "智慧之星",   description: "第一次运行代码",       conditionType: .firstCodeRun,        threshold: 1),
        BadgeDefinition(id: 3,  imageName: "medal_003", title: "逻辑达人",   description: "完成 5 节课程",        conditionType: .completeLessons,     threshold: 5),
        BadgeDefinition(id: 4,  imageName: "medal_004", title: "循环大师",   description: "完成 10 节课程",       conditionType: .completeLessons,     threshold: 10),
        BadgeDefinition(id: 5,  imageName: "medal_005", title: "创意画家",   description: "保存 3 个作品",        conditionType: .saveWorks,           threshold: 3),
        BadgeDefinition(id: 6,  imageName: "medal_006", title: "动画达人",   description: "保存 5 个作品",        conditionType: .saveWorks,           threshold: 5),
        BadgeDefinition(id: 7,  imageName: "medal_007", title: "探索先锋",   description: "完成初级全部课程",     conditionType: .completeLevelLow,    threshold: 1),
        BadgeDefinition(id: 8,  imageName: "medal_008", title: "代码创造者", description: "保存 10 个作品",       conditionType: .saveWorks,           threshold: 10),
        BadgeDefinition(id: 9,  imageName: "medal_009", title: "编程大师",   description: "完成全部 45 节课程",   conditionType: .completeAllLessons,  threshold: 45),
        BadgeDefinition(id: 10, imageName: "medal_010", title: "团队之星",   description: "使用 200 积分兑换",    conditionType: .redeemPoints,        threshold: 200),
        BadgeDefinition(id: 11, imageName: "medal_011", title: "好奇宝宝",   description: "累计发送 30 条消息",   conditionType: .totalMessages,       threshold: 30),
        BadgeDefinition(id: 12, imageName: "medal_012", title: "坚持达人",   description: "连续登录 7 天",        conditionType: .loginStreak,         threshold: 7),
        BadgeDefinition(id: 13, imageName: "medal_013", title: "全能小将",   description: "使用 500 积分兑换",    conditionType: .redeemPoints,        threshold: 500),
    ]

    // MARK: - Step completion tracking (based on lessonMessages)
    var isStep1Done: Bool {
        lessonMessages.contains { $0.role == .user }
    }
    var isStep2Done: Bool {
        lessonMessages.contains { $0.role == .assistant && !$0.content.isEmpty && !$0.content.hasPrefix("⚠️") && !$0.content.hasPrefix("❌") }
    }
    var isStep3Done: Bool {
        hasRunCode
    }
    var completedSteps: Int {
        [isStep1Done, isStep2Done, isStep3Done].filter { $0 }.count
    }
    var progressPercent: Double {
        Double(completedSteps) / 3.0
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "deepseek_api_key") {
            apiKey = saved
        }
        hasAgreedAIConsent = UserDefaults.standard.bool(forKey: "hasAgreedAIConsent")
        loadSavedWorks()
        loadUserStats()
        checkLoginStreak()
    }

    func agreeAIConsent() {
        hasAgreedAIConsent = true
        UserDefaults.standard.set(true, forKey: "hasAgreedAIConsent")
        // 发送之前暂存的消息
        if let msg = pendingAIMessage {
            pendingAIMessage = nil
            if pendingIsLesson {
                sendLessonMessage(msg)
            } else {
                sendMessage(msg)
            }
        }
    }

    func declineAIConsent() {
        showAIConsentDialog = false
        pendingAIMessage = nil
    }

    func saveApiKey(_ key: String) {
        apiKey = key
        UserDefaults.standard.set(key, forKey: "deepseek_api_key")
    }

    func addSystemMessage(_ text: String) {
        chatMessages.append(ChatMessage(role: .system, content: text))
    }

    func clearChat() {
        chatMessages.removeAll()
        chatHistory.removeAll()
        addSystemMessage("🗑️ 对话已清空")
    }

    func clearLessonChat() {
        lessonMessages.removeAll()
        lessonChatHistory.removeAll()
        hasRunCode = false
    }

    // MARK: - Saved Works persistence
    func saveWork(_ work: SavedWork) {
        savedWorks.insert(work, at: 0)
        persistSavedWorks()
        recordWorkSaved()
    }

    func deleteWork(_ work: SavedWork) {
        savedWorks.removeAll { $0.id == work.id }
        persistSavedWorks()
    }

    private func persistSavedWorks() {
        if let data = try? JSONEncoder().encode(savedWorks) {
            UserDefaults.standard.set(data, forKey: "saved_works")
        }
    }

    private func loadSavedWorks() {
        if let data = UserDefaults.standard.data(forKey: "saved_works"),
           let works = try? JSONDecoder().decode([SavedWork].self, from: data) {
            savedWorks = works
        }
    }

    // MARK: - 课程解锁状态
    func lessonStatus(for lessonId: String, in level: Level) -> LessonStatus {
        let lessons = CourseData.lessons(for: level)
        if userStats.completedLessonIds.contains(lessonId) {
            return .completed
        }
        // 第一个未完成的课程可以进入，其余 locked
        for lesson in lessons {
            if !userStats.completedLessonIds.contains(lesson.id) {
                if lesson.id == lessonId {
                    // 已点击进入过 → 进行中，否则 → 待开始
                    return userStats.startedLessonIds.contains(lessonId) ? .inProgress : .notStarted
                } else {
                    return .locked
                }
            }
        }
        return .locked
    }

    // MARK: - 标记课程已开始
    func markLessonStarted(_ lessonId: String) {
        guard !userStats.startedLessonIds.contains(lessonId) else { return }
        userStats.startedLessonIds.insert(lessonId)
        persistUserStats()
    }

    // MARK: - 完成课程
    func markLessonComplete(_ lessonId: String) {
        guard !userStats.completedLessonIds.contains(lessonId) else { return }
        userStats.completedLessonIds.insert(lessonId)
        awardPoints(10) // 完成课程 +10 积分
        checkBadgeUnlocks()
        persistUserStats()
    }

    // MARK: - 运行代码
    func recordCodeRun() {
        userStats.totalCodeRuns += 1
        awardPoints(2) // 运行代码 +2 积分
        checkBadgeUnlocks()
        persistUserStats()
    }

    // MARK: - 发送消息
    func recordMessageSent() {
        userStats.totalMessagesSent += 1
        checkBadgeUnlocks()
        persistUserStats()
    }

    // MARK: - 保存作品
    func recordWorkSaved() {
        userStats.totalWorksSaved += 1
        awardPoints(5) // 保存作品 +5 积分
        checkBadgeUnlocks()
        persistUserStats()
    }

    // MARK: - 积分
    func awardPoints(_ amount: Int) {
        userStats.points += amount
        persistUserStats()
    }

    // MARK: - 积分兑换徽章
    func redeemBadge(_ badgeId: Int) -> Bool {
        guard let badge = Self.allBadges.first(where: { $0.id == badgeId }),
              badge.conditionType == .redeemPoints,
              !userStats.unlockedBadgeIds.contains(badgeId),
              userStats.points >= badge.threshold else { return false }
        userStats.points -= badge.threshold
        userStats.unlockedBadgeIds.insert(badgeId)
        userStats.redeemedBadgeIds.insert(badgeId)
        persistUserStats()
        // Trigger badge unlock animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.newlyUnlockedBadge = badge
        }
        return true
    }

    // MARK: - 登录打卡
    private func checkLoginStreak() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let today = fmt.string(from: Date())
        if userStats.lastLoginDate == today { return }

        if let lastDate = fmt.date(from: userStats.lastLoginDate) {
            let cal = Calendar.current
            if cal.isDate(lastDate, equalTo: cal.date(byAdding: .day, value: -1, to: Date())!, toGranularity: .day) {
                userStats.loginStreak += 1
            } else {
                userStats.loginStreak = 1
            }
        } else {
            userStats.loginStreak = 1
        }
        userStats.totalLogins += 1
        userStats.lastLoginDate = today
        checkBadgeUnlocks()
        persistUserStats()
    }

    // MARK: - 徽章解锁检查
    func checkBadgeUnlocks() {
        let lowLessonIds = Set(CourseData.lowLessons.map { $0.id })
        let allLessonIds = Set(
            CourseData.lowLessons.map { $0.id } +
            CourseData.midLessons.map { $0.id } +
            CourseData.highLessons.map { $0.id }
        )

        // Collect all newly unlocked badges this round
        var newlyUnlocked: [BadgeDefinition] = []

        for badge in Self.allBadges {
            guard !userStats.unlockedBadgeIds.contains(badge.id) else { continue }
            if badge.conditionType == .redeemPoints { continue } // 兑换型不自动解锁

            var shouldUnlock = false
            switch badge.conditionType {
            case .completeFirstLesson:
                shouldUnlock = userStats.completedLessonIds.count >= 1
            case .firstCodeRun:
                shouldUnlock = userStats.totalCodeRuns >= 1
            case .completeLessons:
                shouldUnlock = userStats.completedLessonIds.count >= badge.threshold
            case .saveWorks:
                shouldUnlock = userStats.totalWorksSaved >= badge.threshold
            case .completeLevelLow:
                shouldUnlock = lowLessonIds.isSubset(of: userStats.completedLessonIds)
            case .completeAllLessons:
                shouldUnlock = allLessonIds.isSubset(of: userStats.completedLessonIds)
            case .totalMessages:
                shouldUnlock = userStats.totalMessagesSent >= badge.threshold
            case .loginStreak:
                shouldUnlock = userStats.loginStreak >= badge.threshold
            case .redeemPoints:
                break
            }
            if shouldUnlock {
                userStats.unlockedBadgeIds.insert(badge.id)
                newlyUnlocked.append(badge)
            }
        }

        // Trigger animation for the first newly unlocked badge
        if let first = newlyUnlocked.first, newlyUnlockedBadge == nil {
            // Queue badge animations with delay for multiple unlocks
            badgeUnlockQueue = Array(newlyUnlocked.dropFirst())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.newlyUnlockedBadge = first
            }
        }
    }

    // Queue for multiple badge unlocks
    private var badgeUnlockQueue: [BadgeDefinition] = []

    /// Call when user dismisses the badge overlay
    func dismissBadgeOverlay() {
        newlyUnlockedBadge = nil
        // Show next badge in queue if any
        if !badgeUnlockQueue.isEmpty {
            let next = badgeUnlockQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.newlyUnlockedBadge = next
            }
        }
    }

    // MARK: - 持久化
    private func persistUserStats() {
        if let data = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(data, forKey: "user_stats")
        }
    }

    private func loadUserStats() {
        if let data = UserDefaults.standard.data(forKey: "user_stats"),
           let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = stats
        }
    }

    func startPractice() {
        if apiKey.isEmpty {
            showApiKeySheet = true
            return
        }
        // Navigate to courses tab
        selectedTab = 1
    }

    // MARK: - Send message (Chat tab)
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if apiKey.isEmpty { showApiKeySheet = true; return }
        if !hasAgreedAIConsent {
            pendingAIMessage = trimmed
            pendingIsLesson = false
            showAIConsentDialog = true
            return
        }
        chatMessages.append(ChatMessage(role: .user, content: trimmed))
        chatHistory.append(["role": "user", "content": trimmed])
        recordMessageSent()
        streamResponse(isLesson: false)
    }

    // MARK: - Send message (Lesson detail page)
    func sendLessonMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if apiKey.isEmpty { showApiKeySheet = true; return }
        if !hasAgreedAIConsent {
            pendingAIMessage = trimmed
            pendingIsLesson = true
            showAIConsentDialog = true
            return
        }
        lessonMessages.append(ChatMessage(role: .user, content: trimmed))
        lessonChatHistory.append(["role": "user", "content": trimmed])
        recordMessageSent()
        streamResponse(isLesson: true)
    }

    // MARK: - Unified streaming with context flag
    func streamResponse(isLesson: Bool) {
        if isLesson { isLessonStreaming = true } else { isStreaming = true }

        let assistantMsg = ChatMessage(role: .assistant, content: "")
        if isLesson {
            lessonMessages.append(assistantMsg)
        } else {
            chatMessages.append(assistantMsg)
        }
        let msgIndex = (isLesson ? lessonMessages.count : chatMessages.count) - 1

        let systemPrompt = "你是一个少儿编程教学助手，面向小学生。请用简单易懂的语言回答。当需要生成代码时，请统一生成完整的、可直接运行的HTML+CSS+JavaScript代码，用```html标记。不要生成Python或其他语言的代码。代码要简洁、有趣、适合小学生理解。重要：请尽量精简思考过程，把token留给代码输出，确保代码完整不要被截断。"
        let history = isLesson ? lessonChatHistory : chatHistory
        var messages: [[String: String]] = [["role": "system", "content": systemPrompt]]
        messages.append(contentsOf: history)

        let body: [String: Any] = [
            "model": "deepseek-reasoner",
            "messages": messages,
            "stream": true,
            "max_tokens": 16384
        ]

        guard let url = URL(string: "https://api.deepseek.com/chat/completions"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            if isLesson { isLessonStreaming = false } else { isStreaming = false }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        request.timeoutInterval = 300 // 5 minutes for reasoning model

        let delegate = SSEStreamDelegate(appState: self, msgIndex: msgIndex, isLesson: isLesson)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 600
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        self.activeDelegate = delegate
        task.resume()
    }

    /// Keep a strong reference to the delegate so it's not deallocated
    fileprivate var activeDelegate: SSEStreamDelegate?
}

// MARK: - SSE Stream Delegate for real-time streaming
class SSEStreamDelegate: NSObject, URLSessionDataDelegate {
    private weak var appState: AppState?
    private let msgIndex: Int
    private let isLesson: Bool
    private var buffer = ""
    private var fullContent = ""
    private var fullReasoning = ""

    init(appState: AppState, msgIndex: Int, isLesson: Bool) {
        self.appState = appState
        self.msgIndex = msgIndex
        self.isLesson = isLesson
    }

    /// Helper to get/set the correct message array
    private func getMessages() -> [ChatMessage]? {
        guard let appState = appState else { return nil }
        return isLesson ? appState.lessonMessages : appState.chatMessages
    }

    private func updateMessage(content: String, reasoning: String) {
        guard let appState = appState else { return }
        if isLesson {
            guard msgIndex < appState.lessonMessages.count else { return }
            appState.lessonMessages[msgIndex].content = content
            appState.lessonMessages[msgIndex].reasoningContent = reasoning
        } else {
            guard msgIndex < appState.chatMessages.count else { return }
            appState.chatMessages[msgIndex].content = content
            appState.chatMessages[msgIndex].reasoningContent = reasoning
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk

        while let newlineRange = buffer.range(of: "\n") {
            let line = String(buffer[buffer.startIndex..<newlineRange.lowerBound])
            buffer = String(buffer[newlineRange.upperBound...])

            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if trimmed == "data: [DONE]" {
                DispatchQueue.main.async { [weak self] in self?.finishStream() }
                return
            }

            guard trimmed.hasPrefix("data: ") else { continue }
            let jsonStr = String(trimmed.dropFirst(6))

            guard let jd = jsonStr.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jd) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let delta = choices.first?["delta"] as? [String: Any] else { continue }

            var updated = false
            if let reasoning = delta["reasoning_content"] as? String {
                fullReasoning += reasoning
                updated = true
            }
            if let content = delta["content"] as? String {
                fullContent += content
                updated = true
            }

            if updated {
                let c = fullContent, r = fullReasoning
                DispatchQueue.main.async { [weak self] in
                    self?.updateMessage(content: c, reasoning: r)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let error = error {
                self.updateMessage(content: "❌ 请求失败：\(error.localizedDescription)", reasoning: self.fullReasoning)
            }
            self.finishStream()
        }
    }

    private func finishStream() {
        guard let appState = appState else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isLesson {
                appState.isLessonStreaming = false
                let msgs = appState.lessonMessages
                if self.msgIndex < msgs.count && self.fullContent.isEmpty && self.fullReasoning.isEmpty {
                    appState.lessonMessages[self.msgIndex].content = "⚠️ AI未返回内容，请检查API Key"
                }
                appState.lessonChatHistory.append(["role": "assistant", "content": self.fullContent])
            } else {
                appState.isStreaming = false
                let msgs = appState.chatMessages
                if self.msgIndex < msgs.count && self.fullContent.isEmpty && self.fullReasoning.isEmpty {
                    appState.chatMessages[self.msgIndex].content = "⚠️ AI未返回内容，请检查API Key"
                }
                appState.chatHistory.append(["role": "assistant", "content": self.fullContent])
            }
            appState.activeDelegate = nil
        }
    }
}

