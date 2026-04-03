import Foundation

// MARK: - 年级段
enum Level: String, CaseIterable, Identifiable {
    case low, mid, high
    var id: String { rawValue }

    var name: String {
        switch self {
        case .low: return "初级"
        case .mid: return "中级"
        case .high: return "高级"
        }
    }
    var subtitle: String {
        switch self {
        case .low: return "文字指令启蒙篇 —— AI听我话"
        case .mid: return "文字编程实战篇 —— 用文字做项目"
        case .high: return "提示词工程进阶篇 —— AI项目设计师"
        }
    }
    var icon: String {
        switch self {
        case .low: return "🌱"
        case .mid: return "🌿"
        case .high: return "🌳"
        }
    }
}

// MARK: - 课程
struct Lesson: Identifiable, Equatable {
    let id: String
    let title: String
    let prompt: String
    let goal: String
    let steps: [String]
    let checklist: [String]
    var isTask: Bool = false

    static func == (lhs: Lesson, rhs: Lesson) -> Bool { lhs.id == rhs.id }
}

// MARK: - 聊天消息
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    var content: String
    var reasoningContent: String = ""
    let timestamp = Date()
}

enum MessageRole {
    case user, assistant, system
}

// MARK: - 收藏的作品
struct SavedWork: Identifiable, Codable {
    let id: String
    let title: String
    let lessonTitle: String
    let htmlCode: String
    let category: String   // ANIMATION / LOGIC GAME / AI TOOL
    let createdAt: Date
    var thumbnailData: Data?  // WebView 截图 PNG

    init(id: String = UUID().uuidString, title: String, lessonTitle: String, htmlCode: String, category: String = "ANIMATION", createdAt: Date = Date(), thumbnailData: Data? = nil) {
        self.id = id
        self.title = title
        self.lessonTitle = lessonTitle
        self.htmlCode = htmlCode
        self.category = category
        self.createdAt = createdAt
        self.thumbnailData = thumbnailData
    }
}

// MARK: - 徽章解锁条件
enum BadgeConditionType: String, Codable {
    case completeLessons      // 完成指定数量课程
    case completeFirstLesson  // 完成第一节课
    case firstCodeRun         // 第一次运行代码
    case saveWorks            // 保存指定数量作品
    case completeLevelLow     // 完成初级全部课程
    case completeAllLessons   // 完成全部课程
    case totalMessages        // 发送消息总数
    case loginStreak          // 连续登录天数
    case redeemPoints         // 积分兑换
}

struct BadgeDefinition: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let description: String
    let conditionType: BadgeConditionType
    let threshold: Int  // 条件阈值（数量/积分）
}

// MARK: - 用户统计数据
struct UserStats: Codable {
    var completedLessonIds: Set<String> = []
    var startedLessonIds: Set<String> = []   // 已点击进入过的课程
    var points: Int = 0
    var totalMessagesSent: Int = 0
    var totalCodeRuns: Int = 0
    var totalWorksSaved: Int = 0
    var loginStreak: Int = 0
    var totalLogins: Int = 0       // 累计登录次数
    var lastLoginDate: String = ""  // yyyy-MM-dd
    var unlockedBadgeIds: Set<Int> = []
    var redeemedBadgeIds: Set<Int> = []  // 积分兑换过的徽章
}

