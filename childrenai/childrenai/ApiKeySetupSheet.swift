import SwiftUI

/// 可复用的 DeepSeek API Key 设置弹窗（overlay 风格，和 ProfileView 一致）
struct ApiKeySetupSheet: View {
    @EnvironmentObject var appState: AppState
    @State private var keyInput = ""
    @State private var dialogScale: CGFloat = 0.6
    @State private var dialogOpacity: Double = 0

    var onSave: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { performCancel() }

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
                TextField("sk-xxxxxxxxxxxxxxxx", text: $keyInput)
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
                    Button { performCancel() } label: {
                        Text("取消")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }

                    Button {
                        appState.saveApiKey(keyInput)
                        dismissThen { onSave?() }
                    } label: {
                        Text("保存")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                    .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty)
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
            keyInput = appState.apiKey
            dialogScale = 0.6
            dialogOpacity = 0
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                dialogScale = 1.0
                dialogOpacity = 1.0
            }
        }
    }

    private func performCancel() {
        dismissThen { onCancel?() }
    }

    private func dismissThen(_ completion: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.2)) {
            dialogScale = 0.6
            dialogOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
}
