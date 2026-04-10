import SwiftUI
import WebKit

struct CodePreviewView: View {
    @EnvironmentObject var appState: AppState
    @Binding var htmlCode: String?
    @State private var showSavedToast = false
    @State private var liveWebView: WKWebView? = nil

    var body: some View {
        if let code = htmlCode {
            ZStack {
                VStack(spacing: 0) {
                    // Title bar
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.white)
                        Text("运行效果")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        // 收藏 button
                        Button(action: { saveCurrentWork(code: code) }) {
                            let alreadySaved = appState.savedWorks.contains { $0.htmlCode == code }
                            HStack(spacing: 4) {
                                Image(systemName: alreadySaved ? "heart.fill" : "heart")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(alreadySaved ? "已收藏" : "收藏")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(alreadySaved ? Color(hex: "fb5151") : .white.opacity(0.9))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        Button(action: { htmlCode = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.31, green: 0.80, blue: 0.77), Color(red: 0.2, green: 0.6, blue: 0.6)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                    // WebView
                    WebView(htmlString: code, webViewRef: $liveWebView)
                }
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
                .padding(20)

                // Saved toast
                if showSavedToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DS.Colors.tertiary)
                            Text("已收藏到「成果」")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(DS.Colors.onSurface)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5).ignoresSafeArea())
            .transition(.opacity)
        }
    }

    private func saveCurrentWork(code: String) {
        // Don't save duplicates
        guard !appState.savedWorks.contains(where: { $0.htmlCode == code }) else { return }
        let lessonTitle = appState.selectedLesson?.title ?? "自由创作"

        // Capture screenshot then save
        let doSave: (Data?) -> Void = { thumbnailData in
            let work = SavedWork(
                title: lessonTitle,
                lessonTitle: lessonTitle,
                htmlCode: code,
                category: "ANIMATION",
                thumbnailData: thumbnailData
            )
            appState.saveWork(work)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showSavedToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showSavedToast = false }
            }
        }

        if let webView = liveWebView {
            webView.takeSnapshotAsPNG { data in
                DispatchQueue.main.async { doSave(data) }
            }
        } else {
            doSave(nil)
        }
    }
}

// MARK: - WKWebView Wrapper
struct WebView: UIViewRepresentable {
    let htmlString: String
    /// Optional binding to expose the underlying WKWebView for screenshot capture
    var webViewRef: Binding<WKWebView?>? = nil

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePrefs
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.bounces = true
        DispatchQueue.main.async { webViewRef?.wrappedValue = webView }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// MARK: - WebView Screenshot Helper
extension WKWebView {
    func takeSnapshotAsPNG(completion: @escaping (Data?) -> Void) {
        let config = WKSnapshotConfiguration()
        takeSnapshot(with: config) { image, error in
            guard let image = image else { completion(nil); return }
            completion(image.pngData())
        }
    }
}

