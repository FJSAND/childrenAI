import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()

    /// Track last message content for auto-scroll
    private var lastMessageContent: String {
        let last = appState.chatMessages.last
        return (last?.content ?? "") + (last?.reasoningContent ?? "")
    }

    var body: some View {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: DS.Spacing.md) {
                            ForEach(appState.chatMessages) { msg in
                                ChatBubble(
                                    message: msg,
                                    isStreaming: appState.isStreaming && msg.id == appState.chatMessages.last?.id
                                )
                                .id(msg.id)
                            }
                            // Invisible anchor at the very bottom
                            Color.clear.frame(height: 1).id("chatBottom")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, DS.Spacing.sm)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture { isInputFocused = false }
                    .onChange(of: appState.chatMessages.count, initial: false) {
                        withAnimation { proxy.scrollTo("chatBottom", anchor: .bottom) }
                    }
                    .onChange(of: lastMessageContent, initial: false) {
                        withAnimation { proxy.scrollTo("chatBottom", anchor: .bottom) }
                    }
                }

                // Input bar
                inputBar
            }
            .background(DS.Colors.surface.ignoresSafeArea())
            .navigationTitle("魔法画室")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DS.Colors.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { appState.clearChat() }) {
                        Image(systemName: "trash")
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                    }
                }
            }
            .onAppear {
                if let lesson = appState.selectedLesson, inputText.isEmpty {
                    inputText = lesson.prompt
                }
            }
            .navigationBarBackButtonHidden(true)
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            // Recording indicator
            if speechRecognizer.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(speechRecognizer.isRecording ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: speechRecognizer.isRecording)
                    Text("正在听你说话...")
                        .font(.system(size: 13))
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            HStack(spacing: 0) {
                // Mic button
                Button(action: { toggleVoiceInput() }) {
                    Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(speechRecognizer.isRecording ? .red : DS.Colors.primary.opacity(0.45))
                        .frame(width: 44, height: 44)
                        .scaleEffect(speechRecognizer.isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: speechRecognizer.isRecording)
                }

                // Text field
                TextField("告诉我你的奇思妙想...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.onSurface)
                    .lineLimit(1...4)
                    .focused($isInputFocused)

                // Magic button (inside the pill)
                Button(action: { sendMessage() }) {
                    HStack(spacing: 5) {
                        Text("魔法")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.isStreaming
                            ? DS.Colors.outlineVariant
                            : DS.Colors.primary
                    )
                    .clipShape(Capsule())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.isStreaming)
                .padding(.trailing, 8)
            }
            .padding(.vertical, 5)
            .background(DS.Colors.surfaceContainerLow)
            .clipShape(Capsule())
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .padding(.bottom, DS.Spacing.sm)
        .background(
            DS.Colors.surfaceContainerLowest
                .shadow(.drop(color: DS.Shadow.ambient, radius: 8, y: -4))
        )
        .onChange(of: speechRecognizer.transcript, initial: false) {
            if !speechRecognizer.transcript.isEmpty {
                inputText = speechRecognizer.transcript
            }
        }
        .alert("语音输入提示", isPresented: .init(
            get: { speechRecognizer.errorMessage != nil },
            set: { if !$0 { speechRecognizer.errorMessage = nil } }
        )) {
            Button("好的", role: .cancel) { }
        } message: {
            Text(speechRecognizer.errorMessage ?? "")
        }
    }

    private func toggleVoiceInput() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            isInputFocused = false
            speechRecognizer.startRecording()
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isInputFocused = false
        appState.sendMessage(text)
    }
}

