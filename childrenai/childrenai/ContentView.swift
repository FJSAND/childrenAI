import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKeyInput = ""
    @State private var dialogScale: CGFloat = 0.6
    @State private var dialogOpacity: Double = 0

    // Welcome dialog
    @State private var showWelcomeDialog = false
    @State private var welcomeScale: CGFloat = 0.6
    @State private var welcomeOpacity: Double = 0

    // AI consent dialog
    @State private var consentScale: CGFloat = 0.6
    @State private var consentOpacity: Double = 0
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                NavigationStack(path: $appState.homePath) {
                    HomeView()
                        .navigationDestination(for: String.self) { dest in
                            if dest == "chat" { ChatView() }
                        }
                }
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                    .tag(0)

                NavigationStack { CourseListView() }
                    .tabItem {
                        Label("课程", systemImage: "book.fill")
                    }
                    .tag(1)

                NavigationStack(path: $appState.achievementsPath) {
                    AchievementsView()
                        .navigationDestination(for: String.self) { dest in
                            if dest == "chat" { ChatView() }
                        }
                }
                    .tabItem {
                        Label("成果", systemImage: "trophy.fill")
                    }
                    .tag(2)

                NavigationStack {
                    ProfileView()
                        .navigationDestination(for: String.self) { dest in
                            if dest == "allBadges" { AllBadgesView() }
                        }
                }
                    .tabItem {
                        Label("我的", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .tint(DS.Colors.primary)

            // Code preview overlay
            if appState.codeToPreview != nil {
                CodePreviewView(htmlCode: $appState.codeToPreview)
                    .animation(.easeInOut(duration: 0.3), value: appState.codeToPreview != nil)
            }

            // Badge unlock celebration overlay
            if let badge = appState.newlyUnlockedBadge {
                BadgeUnlockOverlay(badge: badge) {
                    appState.dismissBadgeOverlay()
                }
                .transition(.opacity)
                .zIndex(999)
            }

            // Global API Key dialog (replaces old sheet)
            if appState.showApiKeySheet {
                globalApiKeyDialog
                    .zIndex(998)
            }

            // Welcome dialog (first launch)
            if showWelcomeDialog {
                welcomeDialogOverlay
                    .zIndex(997)
            }

            // AI consent dialog
            if appState.showAIConsentDialog {
                aiConsentDialogOverlay
                    .zIndex(996)
            }
        }
        .onAppear {
            let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            if !hasLaunched {
                showWelcomeDialog = true
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
        }
    }

    // MARK: - Global API Key Dialog
    private var globalApiKeyDialog: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { dismissGlobalDialog() }

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
                    Button { dismissGlobalDialog() } label: {
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
                        dismissGlobalDialog()
                    } label: {
                        Text("保存")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                    .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)
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
            apiKeyInput = appState.apiKey
            dialogScale = 0.6
            dialogOpacity = 0
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                dialogScale = 1.0
                dialogOpacity = 1.0
            }
        }
    }

    private func dismissGlobalDialog() {
        withAnimation(.easeOut(duration: 0.2)) {
            dialogScale = 0.6
            dialogOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            appState.showApiKeySheet = false
        }
    }

    // MARK: - Welcome Dialog (First Launch)
    private var welcomeDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: DS.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DS.Colors.primaryContainer.opacity(0.3))
                            .frame(width: 64, height: 64)
                        Text("👋")
                            .font(.system(size: 32))
                    }

                    Text("欢迎来到萌码")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DS.Colors.onBackground)

                    Text("萌码是一款专为少儿打造的 AI 启蒙应用。\n在这里，孩子可以与 AI 自由对话、探索 AI 的奇妙能力，在趣味互动中轻松学会用文字指令进行创作。\n\n完全免费，放心使用 🎉")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, DS.Spacing.lg + 4)
                .padding(.horizontal, DS.Spacing.lg)

                Button { dismissWelcomeDialog() } label: {
                    Text("开始探索")
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
            .scaleEffect(welcomeScale)
            .opacity(welcomeOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                welcomeScale = 1.0
                welcomeOpacity = 1.0
            }
        }
    }

    private func dismissWelcomeDialog() {
        withAnimation(.easeOut(duration: 0.2)) {
            welcomeScale = 0.6
            welcomeOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showWelcomeDialog = false
        }
    }

    // MARK: - AI Consent Dialog
    private var aiConsentDialogOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: DS.Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(DS.Colors.primaryContainer.opacity(0.3))
                                .frame(width: 56, height: 56)
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 24))
                                .foregroundColor(DS.Colors.primary)
                        }

                        Text("第三方 AI 服务数据授权")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DS.Colors.onBackground)
                    }
                    .padding(.top, DS.Spacing.lg)
                    .padding(.horizontal, DS.Spacing.lg)

                    // Detailed disclosure
                    VStack(alignment: .leading, spacing: 12) {
                        consentInfoRow(icon: "doc.text", title: "发送的数据",
                            detail: "您在对话中输入的文字消息将被发送至第三方服务以生成 AI 回复。我们不会发送您的姓名、手机号、位置或其他个人身份信息。")

                        consentInfoRow(icon: "building.2", title: "数据接收方",
                            detail: "您的对话内容将发送至 DeepSeek（深度求索，deepseek.com），由其 AI 模型处理并返回回复内容。")

                        consentInfoRow(icon: "shield.checkered", title: "数据保护",
                            detail: "数据通过 HTTPS 加密传输。DeepSeek 按其隐私政策处理数据，不会将您的对话内容用于向第三方营销。")

                        consentInfoRow(icon: "xmark.circle", title: "拒绝的影响",
                            detail: "如果您不同意，将无法使用 AI 对话功能，但仍可浏览课程内容。")
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.md)

                    // Privacy policy link
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 12))
                            Text("查看完整隐私政策")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(DS.Colors.primary)
                    }
                    .padding(.top, DS.Spacing.sm)

                    HStack(spacing: DS.Spacing.md) {
                        Button {
                            dismissConsentDialog()
                            appState.declineAIConsent()
                        } label: {
                            Text("不同意")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(DS.Colors.onSurfaceVariant)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(DS.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                        }

                        Button {
                            dismissConsentDialog()
                            appState.agreeAIConsent()
                        } label: {
                            Text("同意并继续")
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
                .padding(.horizontal, 28)
                .padding(.vertical, 60)
            }
            .scaleEffect(consentScale)
            .opacity(consentOpacity)
        }
        .onAppear {
            consentScale = 0.6
            consentOpacity = 0
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                consentScale = 1.0
                consentOpacity = 1.0
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }

    private func consentInfoRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.primary)
                .frame(width: 24, height: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DS.Colors.onSurface)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func dismissConsentDialog() {
        withAnimation(.easeOut(duration: 0.2)) {
            consentScale = 0.6
            consentOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            appState.showAIConsentDialog = false
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var keyInput = ""

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                // API Section
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    Label("API 设置", systemImage: "key.fill")
                        .font(.headline).foregroundColor(DS.Colors.primary)

                    TextField("DeepSeek API Key", text: $keyInput)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .padding(DS.Spacing.md)
                        .background(DS.Colors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

                    Button(action: { appState.saveApiKey(keyInput) }) {
                        Text("保存").font(.headline).fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty)

                    if !appState.apiKey.isEmpty {
                        Label("API Key 已设置", systemImage: "checkmark.seal.fill")
                            .foregroundColor(DS.Colors.tertiary)
                            .font(.subheadline).fontWeight(.bold)
                    }
                }
                .padding(DS.Spacing.lg)
                .background(DS.Colors.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .ambientShadow()

                // About Section
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    Label("关于", systemImage: "info.circle.fill")
                        .font(.headline).foregroundColor(DS.Colors.primary)
                    HStack { Text("版本").foregroundColor(DS.Colors.onSurface); Spacer(); Text("1.0.0").foregroundColor(DS.Colors.onSurfaceVariant) }
                    HStack { Text("作者").foregroundColor(DS.Colors.onSurface); Spacer(); Text("大朗拿度").foregroundColor(DS.Colors.onSurfaceVariant) }
                }
                .padding(DS.Spacing.lg)
                .background(DS.Colors.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .ambientShadow()
            }
            .padding(DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
        }
        .background(DS.Colors.surface.ignoresSafeArea())
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { keyInput = appState.apiKey }
    }
}

// MARK: - API Key Sheet
struct ApiKeySheet: View {
    @EnvironmentObject var appState: AppState
    @State private var keyInput = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.lg) {
                ZStack {
                    Circle().fill(DS.Colors.secondaryContainer.opacity(0.3)).frame(width: 100, height: 100)
                    Image(systemName: "key.fill")
                        .font(.system(size: 42))
                        .foregroundColor(DS.Colors.secondary)
                }
                Text("请先设置 API Key")
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(DS.Colors.onBackground)
                Text("需要 DeepSeek API Key 才能使用 AI 对话功能")
                    .font(.subheadline)
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                TextField("输入 API Key", text: $keyInput)
                    .autocorrectionDisabled()
                    .padding(DS.Spacing.md)
                    .background(DS.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    .padding(.horizontal)

                Button(action: {
                    appState.saveApiKey(keyInput)
                    dismiss()
                    appState.startPractice()
                }) {
                    Text("保存并开始")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(DS.Colors.primary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                }
                .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 40)
            .background(DS.Colors.surface.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") { dismiss() }.foregroundColor(DS.Colors.primary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
