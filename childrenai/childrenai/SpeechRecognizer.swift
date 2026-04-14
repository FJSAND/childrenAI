import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthorized: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        // 不在初始化时请求权限，等用户主动点击麦克风且同意AI授权后再请求
    }

    // MARK: - Authorization
    /// 仅在用户主动触发时才请求权限，避免进入页面就弹系统弹窗
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        let currentStatus = SFSpeechRecognizer.authorizationStatus()
        switch currentStatus {
        case .authorized:
            isAuthorized = true
            completion(true)
        case .denied:
            errorMessage = "语音识别权限被拒绝，请在「设置 → 隐私 → 语音识别」中开启"
            isAuthorized = false
            completion(false)
        case .restricted:
            errorMessage = "语音识别在此设备上不可用"
            isAuthorized = false
            completion(false)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    switch status {
                    case .authorized:
                        self?.isAuthorized = true
                        completion(true)
                    default:
                        self?.errorMessage = "需要语音识别权限才能使用语音输入"
                        self?.isAuthorized = false
                        completion(false)
                    }
                }
            }
        @unknown default:
            isAuthorized = false
            completion(false)
        }
    }

    // MARK: - Toggle
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    // MARK: - Start Recording
    func startRecording() {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "语音识别不可用"
            return
        }

        // Reset
        recognitionTask?.cancel()
        recognitionTask = nil
        transcript = ""
        errorMessage = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "无法启动录音: \(error.localizedDescription)"
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal == true) {
                    self?.stopRecording()
                }
            }
        }

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "录音启动失败: \(error.localizedDescription)"
            stopRecording()
        }
    }

    // MARK: - Stop Recording
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

