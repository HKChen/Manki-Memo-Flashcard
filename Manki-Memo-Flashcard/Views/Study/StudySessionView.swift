//
//  StudySessionView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/26.
//

import SwiftUI
import AVFoundation
import Translation

struct StudySessionView: View {
    let cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var isTranslationRevealed = false
    @State private var speechService = SpeechService()
    
    // Translation Framework State
    @State private var translationConfig: TranslationSession.Configuration?
    @State private var translatedText: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var currentCard: FlashCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) / \(cards.count)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
                .padding()
                
                Spacer()
                
                if let card = currentCard {
                    MujiCard(padding: 24) {
                        VStack(spacing: 40) {
                            // Japanese Text (Always visible)
                            Text(card.japanese)
                                .font(.system(size: 48, weight: .bold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(.horizontal)
                                .onTapGesture {
                                     speechService.speak(card.japanese)
                                }
                            
                            // Audio Button
                            Button {
                                speechService.speak(card.japanese)
                            } label: {
                                HStack {
                                    Image(systemName: "speaker.wave.2.circle.fill")
                                        .font(.largeTitle)
                                    Text("發音")
                                        .font(.headline)
                                }
                                .foregroundColor(AppTheme.Colors.accent)
                            }
                            .disabled(speechService.isSpeaking)
                            
                            Divider()
                                .padding(.vertical)
                                .frame(maxWidth: 200)
                            
                            // Translation (Hidden initially)
                            Group {
                                if isTranslationRevealed {
                                    VStack(spacing: 8) {
                                        if !translatedText.isEmpty {
                                            Text(translatedText)
                                                .font(.system(size: 32, weight: .medium))
                                                .multilineTextAlignment(.center)
                                                .foregroundStyle(AppTheme.Colors.primaryText)
                                        } else {
                                            // Fallback or loading
                                            ProgressView()
                                                .controlSize(.large)
                                                .tint(AppTheme.Colors.accent)
                                        }
                                        
                                        // Optional: Show original user translation as reference
                                        Text("原文: \(card.translation)")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.Colors.secondaryText)
                                            .padding(.top, 4)
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                } else {
                                    Button {
                                        withAnimation(.spring()) {
                                            isTranslationRevealed = true
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: "eye.fill")
                                                .font(.title)
                                            Text("顯示翻譯")
                                                .font(.headline)
                                        }
                                        .padding(30)
                                        .frame(maxWidth: .infinity)
                                        .background(AppTheme.Colors.background)
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .overlay(
                                            Rectangle()
                                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .frame(minHeight: 120)
                        }
                    }
                    .padding(.horizontal)
                    
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.Colors.accent)
                        Text("學習完成！")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(AppTheme.Colors.primaryText)
                    }
                }
                
                Spacer()
                
                // Footer
                Button {
                    nextCard()
                } label: {
                    HStack {
                        Text(currentIndex < cards.count - 1 ? "下一個" : "完成")
                            .bold()
                        if currentIndex < cards.count - 1 {
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .buttonStyle(MujiButtonStyle(isPrimary: true))
                .padding()
            }
        }
        .translationTask(translationConfig) { session in
            guard let card = currentCard else { return }
            do {
                let response = try await session.translate(card.japanese)
                await MainActor.run {
                    self.translatedText = response.targetText
                }
            } catch {
                print("Translation failed: \(error)")
                // Fallback to manual translation on error
                await MainActor.run {
                    self.translatedText = card.translation
                }
            }
        }
        .onChange(of: currentIndex, initial: true) {
             triggerTranslation()
        }
    }
    
    private func triggerTranslation() {
        guard currentCard != nil else { return }
        // Reset translation
        translatedText = ""
        
        // Setup configuration for the new card
        // Ja -> Traditional Chinese
        if #available(iOS 18.0, *) {
            translationConfig = TranslationSession.Configuration(
                source: Locale.Language(identifier: "ja"),
                target: Locale.Language(identifier: "zh-Hant")
            )
        }
    }
    
    private func nextCard() {
        if currentIndex < cards.count - 1 {
            withAnimation {
                currentIndex += 1
                isTranslationRevealed = false
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    StudySessionView(cards: [
        FlashCard(japanese: "猫", translation: "貓"),
        FlashCard(japanese: "犬", translation: "狗")
    ])
}
