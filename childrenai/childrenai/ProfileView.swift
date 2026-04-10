import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showApiKeyDialog = false
    @State private var showAboutDialog = false
    @State private var apiKeyInput = ""
    @State private var dialogScale: CGFloat = 0.6
    @State private var dialogOpacity: Double = 0
    @State private var aboutDialogScale: CGFloat = 0.6
    @State private var aboutDialogOpacity: Double = 0
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    heroSection
                    statsRow
                    badgesSection
                    settingsSection
                }
                .padding(.bottom, 40)
            }
            .background(DS.Colors.surface.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)

            // MARK: - Custom API Key Dialog
            if showApiKeyDialog {
                apiKeyDialogOverlay
            }

            // MARK: - About Dialog
            if showAboutDialog {
                aboutDialogOverlay
            }
        }
    }

    // MARK: - Dialog Overlay
    private var apiKeyDialogOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { dismissDialog() }

            // Dialog card
            VStack(spacing: 0) {
                // Header
                VStack(spacing: DS.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DS.Colors.primaryContainer.opacity(0.3))
                            .frame(width: 56, height: 56)
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DS.Colors.primary)
                    }

                    Text("DeepSeek 设置")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DS.Colors.onBackground)

                    Text("请输入 DeepSeek API Key 以启用 AI 功能")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DS.Spacing.lg)
                .padding(.horizontal, DS.Spacing.lg)

                // Input field
                TextField("sk-xxxxxxxxxxxxxxxx", text: $apiKeyInput)
                    .font(.system(size: 15, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(DS.Spacing.md)
                    .background(DS.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(DS.Colors.outlineVariant.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.lg)

                // Hint link
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 11))
                    Text("点击前往 platform.deepseek.com 获取")
                        .font(.system(size: 12))
                }
                .foregroundColor(DS.Colors.primary.opacity(0.8))
                .padding(.top, DS.Spacing.sm)
                .onTapGesture {
                    if let url = URL(string: "https://platform.deepseek.com") {
                        UIApplication.shared.open(url)
                    }
                }

                // Buttons
                HStack(spacing: DS.Spacing.md) {
                    Button { dismissDialog() } label: {
                        Text("取消")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }

                    Button {
                        appState.saveApiKey(apiKeyInput)
                        dismissDialog()
                    } label: {
                        Text("保存")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .background(DS.Colors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: DS.Colors.onBackground.opacity(0.15), radius: 30, y: 15)
            .padding(.horizontal, 36)
            .scaleEffect(dialogScale)
            .opacity(dialogOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                dialogScale = 1.0
                dialogOpacity = 1.0
            }
        }
    }

    private func showDialog() {
        apiKeyInput = appState.apiKey
        dialogScale = 0.6
        dialogOpacity = 0
        showApiKeyDialog = true
    }

    private func dismissDialog() {
        withAnimation(.easeOut(duration: 0.2)) {
            dialogScale = 0.6
            dialogOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showApiKeyDialog = false
        }
    }

    // MARK: - About Dialog Overlay
    private var aboutDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { dismissAboutDialog() }

            VStack(spacing: 0) {
                // Header icon
                VStack(spacing: DS.Spacing.sm) {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("萌码")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DS.Colors.onBackground)

                    Text("少儿 AI 编程启蒙")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                }
                .padding(.top, DS.Spacing.lg)
                .padding(.horizontal, DS.Spacing.lg)

                // Info rows
                VStack(spacing: 0) {
                    aboutInfoRow(label: "版本", value: "1.0.0")
                    Divider().padding(.leading, 20)
                    aboutInfoRow(label: "作者", value: "大朗拿度")
                }
                .padding(.top, DS.Spacing.lg)

                // Close button
                Button { dismissAboutDialog() } label: {
                    Text("好的")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .padding(DS.Spacing.lg)
            }
            .background(DS.Colors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            .shadow(color: DS.Colors.onBackground.opacity(0.15), radius: 30, y: 15)
            .padding(.horizontal, 36)
            .scaleEffect(aboutDialogScale)
            .opacity(aboutDialogOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                aboutDialogScale = 1.0
                aboutDialogOpacity = 1.0
            }
        }
    }

    private func aboutInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DS.Colors.onSurface)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.onSurfaceVariant)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func showAboutDialogAction() {
        aboutDialogScale = 0.6
        aboutDialogOpacity = 0
        showAboutDialog = true
    }

    private func dismissAboutDialog() {
        withAnimation(.easeOut(duration: 0.2)) {
            aboutDialogScale = 0.6
            aboutDialogOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showAboutDialog = false
        }
    }
}

// MARK: - Growth Title (与 HomeView 统一)
extension ProfileView {
    var growthTitle: String {
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

    var growthIcon: String {
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
}

// MARK: - Hero Section
extension ProfileView {
    var heroSection: some View {
        VStack(spacing: DS.Spacing.md) {
            // Avatar with sparkle badge
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(DS.Colors.primaryContainer)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Text("🧑‍🚀")
                            .font(.system(size: 64))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 6)
                    )
                    .shadow(color: DS.Colors.onBackground.opacity(0.06), radius: 20, y: 10)

                // Sparkle badge
                ZStack {
                    Circle()
                        .fill(DS.Colors.tertiaryContainer)
                        .frame(width: 36, height: 36)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.Colors.tertiary)
                }
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(x: -4, y: -4)
            }

            Text(growthTitle)
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(DS.Colors.onBackground)
        }
        .padding(.top, DS.Spacing.lg)
    }
}

// MARK: - Stats Row
extension ProfileView {
    var statsRow: some View {
        HStack(spacing: DS.Spacing.md) {
            statCard(value: "\(appState.userStats.points)", label: "积分", color: DS.Colors.primary)
            statCard(value: "\(appState.userStats.completedLessonIds.count)", label: "课程", color: DS.Colors.secondary)
            statCard(value: "\(appState.userStats.unlockedBadgeIds.count)", label: "徽章", color: DS.Colors.tertiary)
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .shadow(color: DS.Colors.onBackground.opacity(0.06), radius: 20, y: 10)
    }
}


// MARK: - Badges Section
extension ProfileView {
    var badgesSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Text("我的徽章")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(DS.Colors.onBackground)
                Spacer()
                NavigationLink(value: "allBadges") {
                    Text("查看全部")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.Colors.primary)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(AppState.allBadges) { badge in
                        let unlocked = appState.userStats.unlockedBadgeIds.contains(badge.id)
                        VStack(spacing: DS.Spacing.sm) {
                            Image(badge.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            Text(badge.title)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(DS.Colors.onBackground)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                        }
                        .padding(.vertical, DS.Spacing.md)
                        .padding(.horizontal, DS.Spacing.sm)
                        .frame(width: 110)
                        .background(DS.Colors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .opacity(unlocked ? 1 : 0.5)
                        .grayscale(unlocked ? 0 : 1)
                        .onTapGesture {
                            if unlocked {
                                appState.newlyUnlockedBadge = badge
                            }
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
        }
    }
}

// MARK: - Settings & Support
extension ProfileView {
    var settingsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("设置与支持")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(DS.Colors.onBackground)
                .padding(.horizontal, DS.Spacing.lg)

            VStack(spacing: 0) {
                // 大模型设置 — 弹出 API Key 输入框
                Button {
                    showDialog()
                } label: {
                    settingsRowContent(icon: "cpu.fill", title: "DeepSeek 设置")
                }
                .buttonStyle(.plain)

                dividerLine

                Button {
                    showAboutDialogAction()
                } label: {
                    settingsRowContent(icon: "info.circle", title: "关于")
                }
                .buttonStyle(.plain)

                dividerLine
                Button {
                    showPrivacyPolicy = true
                } label: {
                    settingsRowContent(icon: "shield.fill", title: "隐私政策")
                }
                .buttonStyle(.plain)


            }
            .background(DS.Colors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .padding(.horizontal, DS.Spacing.lg)
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }

    private var dividerLine: some View {
        Divider().padding(.leading, 56)
    }

    private func settingsRowContent(icon: String, title: String) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DS.Colors.onBackground)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DS.Colors.onSurfaceVariant)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}
