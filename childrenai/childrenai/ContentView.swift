import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState


    // Welcome dialog
    @State private var showWelcomeDialog = false
    @State private var welcomeScale: CGFloat = 0.6
    @State private var welcomeOpacity: Double = 0



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

            // Global API Key dialog
            if appState.showApiKeySheet {
                ApiKeySetupSheet(onSave: {
                    appState.showApiKeySheet = false
                }, onCancel: {
                    appState.showApiKeySheet = false
                })
                .zIndex(998)
            }

            // Welcome dialog (first launch)
            if showWelcomeDialog {
                welcomeDialogOverlay
                    .zIndex(997)
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
