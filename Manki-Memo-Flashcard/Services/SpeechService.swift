//
//  SpeechService.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import AVFoundation
import Observation

enum SpeechRate: Float, CaseIterable, Sendable {
    case slow = 0.3
    case normal = 0.5
    case fast = 0.6

    var displayName: String {
        switch self {
        case .slow: return "慢速"
        case .normal: return "正常"
        case .fast: return "快速"
        }
    }
}

@Observable
@MainActor
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()

    var isSpeaking: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, rate: SpeechRate = .normal) {
        guard !text.isEmpty else { return }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = rate.rawValue
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
