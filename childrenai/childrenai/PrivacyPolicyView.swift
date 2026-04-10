import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        sectionTitle("萌码 隐私政策")
                        Text("最后更新日期：2026年4月10日")
                            .font(.system(size: 13))
                            .foregroundColor(DS.Colors.onSurfaceVariant)

                        bodyText("「萌码」（以下简称"本应用"）由开发者运营，致力于为少儿提供 AI 编程启蒙教育服务。我们非常重视用户隐私保护。本隐私政策旨在向您说明本应用如何收集、使用、存储和共享您的信息。")
                    }

                    Group {
                        sectionTitle("一、我们收集的数据")
                        bulletPoint("对话内容", "您在与 AI 助手交互时输入的文字消息。这些内容仅用于生成 AI 回复，不与您的真实身份关联。")
                        bulletPoint("API Key", "您主动输入的 DeepSeek API Key，仅存储在您的设备本地（UserDefaults），不会上传至我们的服务器。")
                        bulletPoint("学习进度", "课程完成状态、积分、徽章等数据，仅存储在您的设备本地，不会上传至任何服务器。")
                        bulletPoint("语音数据", "若您使用语音输入功能，语音将通过 Apple 的 Speech 框架在设备本地转换为文字，原始语音数据不会发送给第三方。")
                        bodyText("本应用不收集您的姓名、电话号码、电子邮件、地理位置、设备标识符或其他个人身份信息。")
                    }

                    Group {
                        sectionTitle("二、数据的使用方式")
                        bodyText("• 对话内容：仅用于发送至第三方 AI 服务以生成回复，不做其他用途\n• API Key：仅用于验证 AI 服务的访问权限\n• 学习进度：仅用于在应用内展示您的学习成果")
                    }

                    Group {
                        sectionTitle("三、第三方数据共享")
                        bodyText("本应用使用以下第三方服务：")
                        bulletPoint("DeepSeek（深度求索）", "您输入的对话文字内容将通过 HTTPS 加密传输发送至 DeepSeek 的 API 服务（api.deepseek.com），由其 AI 模型处理并生成回复。DeepSeek 的隐私政策请参阅：https://www.deepseek.com/privacy")
                        bulletPoint("Apple Speech Framework", "语音识别在设备本地处理，遵循 Apple 的隐私政策。")
                        bodyText("除上述服务外，我们不会将您的任何数据分享给其他第三方。DeepSeek 承诺对用户数据提供与本应用同等或更高级别的保护。")
                    }

                    Group {
                        sectionTitle("四、数据存储与安全")
                        bodyText("• 所有用户数据（API Key、学习进度、徽章）均存储在您的设备本地\n• 与 DeepSeek 的数据传输通过 HTTPS/TLS 加密\n• 本应用不设有独立的后端服务器，不存储任何用户数据\n• 删除应用即可清除所有本地数据")
                    }

                    Group {
                        sectionTitle("五、用户权利")
                        bodyText("• 您可以随时在应用内拒绝 AI 数据共享授权\n• 您可以随时删除应用以清除所有本地数据\n• 您可以选择不使用语音输入功能\n• 您可以随时更换或删除 API Key")
                    }

                    Group {
                        sectionTitle("六、儿童隐私保护")
                        bodyText("本应用面向少儿用户设计。我们不会主动收集任何可识别儿童身份的个人信息。建议家长或监护人指导儿童使用本应用，并在必要时协助设置 API Key。")
                    }

                    Group {
                        sectionTitle("七、隐私政策的变更")
                        bodyText("我们可能会不时更新本隐私政策。更新后的政策将在应用内发布，并更新「最后更新日期」。继续使用本应用即表示您同意更新后的隐私政策。")
                    }

                    Group {
                        sectionTitle("八、联系我们")
                        bodyText("如您对本隐私政策有任何疑问，请通过以下方式联系我们：\n\n邮箱：fjsand@foxmail.com")
                    }
                }
                .padding(DS.Spacing.lg)
                .padding(.bottom, 40)
            }
            .background(DS.Colors.surface.ignoresSafeArea())
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(DS.Colors.primary)
                }
            }
        }
    }

    // MARK: - Helpers
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(DS.Colors.onBackground)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(DS.Colors.onSurfaceVariant)
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func bulletPoint(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(DS.Colors.primary)
                .frame(width: 6, height: 6)
                .padding(.top, 7)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.onSurface)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.onSurfaceVariant)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
