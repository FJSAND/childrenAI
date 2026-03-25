import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    var isStreaming: Bool = false

    var body: some View {
        switch message.role {
        case .system:  systemBubble
        case .user:    userBubble
        case .assistant: assistantBubble
        }
    }

    private var systemBubble: some View {
        Text(message.content)
            .font(.caption).foregroundColor(DS.Colors.onSurfaceVariant)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(DS.Colors.surfaceContainerLow)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 60)
            Text(message.content)
                .font(.body).foregroundColor(.white)
                .padding(DS.Spacing.md)
                .background(DS.Colors.primary)
                .cornerRadius(DS.Radius.lg, corners: [.topLeft, .topRight, .bottomLeft])
        }
    }

    /// Split message content into text segments and code blocks
    private func parseContent(_ content: String) -> [(type: String, text: String)] {
        var parts: [(type: String, text: String)] = []
        let pattern = "```(\\w*)\\s*\\n([\\s\\S]*?)(?:```|$)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [("text", content)]
        }
        var lastEnd = content.startIndex
        let nsContent = content as NSString
        let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsContent.length))

        for match in matches {
            let matchRange = Range(match.range, in: content)!
            // Text before this code block
            if lastEnd < matchRange.lowerBound {
                let textBefore = String(content[lastEnd..<matchRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !textBefore.isEmpty { parts.append(("text", textBefore)) }
            }
            let lang = match.numberOfRanges > 1 ? (Range(match.range(at: 1), in: content).map { String(content[$0]) } ?? "") : ""
            let code = match.numberOfRanges > 2 ? (Range(match.range(at: 2), in: content).map { String(content[$0]) } ?? "") : ""
            parts.append(("code:\(lang)", code))
            lastEnd = matchRange.upperBound
        }
        // Remaining text after last code block
        if lastEnd < content.endIndex {
            let remaining = String(content[lastEnd...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !remaining.isEmpty { parts.append(("text", remaining)) }
        }
        if parts.isEmpty { parts.append(("text", content)) }
        return parts
    }

    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Thinking / reasoning section
            if !message.reasoningContent.isEmpty {
                DisclosureGroup {
                    Text(message.reasoningContent)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                        .textSelection(.enabled)
                } label: {
                    HStack(spacing: 4) {
                        Text("思考过程")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(DS.Colors.primary.opacity(0.7))
                }
                .tint(DS.Colors.primary.opacity(0.7))
            }

            if message.content.isEmpty && message.reasoningContent.isEmpty {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7).tint(DS.Colors.primary)
                    Text("思考中...").font(.caption).foregroundColor(DS.Colors.onSurfaceVariant)
                }
            } else if message.content.isEmpty && !message.reasoningContent.isEmpty {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7).tint(DS.Colors.primary)
                    Text("正在思考...").font(.caption).foregroundColor(DS.Colors.onSurfaceVariant)
                }
            } else {
                let parts = parseContent(message.content)
                ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                    if part.type == "text" {
                        Text(part.text)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(DS.Colors.onSurface)
                            .textSelection(.enabled)
                    } else {
                        codeBlockView(code: part.text, lang: String(part.type.dropFirst(5)))
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.surfaceContainerLowest)
        .cornerRadius(DS.Radius.lg, corners: [.topLeft, .topRight, .bottomRight])
        .ambientShadow()
    }

    private func codeBlockView(code: String, lang: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 11, weight: .bold))
                Text(lang.isEmpty ? "代码" : lang.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                Spacer()
                if isStreaming {
                    HStack(spacing: 4) {
                        ProgressView().scaleEffect(0.6).tint(.white.opacity(0.7))
                        Text("生成中...").font(.system(size: 11))
                    }
                } else {
                    CopyCodeButton(code: code)
                }
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.18, green: 0.20, blue: 0.25))

            // Code content — both horizontal and vertical scrolling
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                Text(code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95))
                    .textSelection(.enabled)
                    .padding(12)
                    .fixedSize(horizontal: true, vertical: true)
            }
            .frame(maxHeight: 260)
            .background(Color(red: 0.13, green: 0.15, blue: 0.18))

            // Run button — only after streaming finished & html code
            if !isStreaming && lang == "html" {
                RunCodeButton(content: message.content)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.13, green: 0.15, blue: 0.18))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Copy Code Button
struct CopyCodeButton: View {
    let code: String
    @State private var copied = false

    var body: some View {
        Button(action: {
            UIPasteboard.general.string = code
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
        }) {
            HStack(spacing: 3) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 10, weight: .semibold))
                Text(copied ? "已复制" : "复制")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.white.opacity(copied ? 1 : 0.7))
        }
    }
}

// MARK: - Run Code Button
struct RunCodeButton: View {
    let content: String
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: {
            let pattern = "```html\\s*\\n([\\s\\S]*?)```"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
               let range = Range(match.range(at: 1), in: content) {
                appState.codeToPreview = String(content[range])
                appState.hasRunCode = true
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "play.fill").font(.caption)
                Text("运行代码看效果").font(.caption).fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(DS.Colors.tertiary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

