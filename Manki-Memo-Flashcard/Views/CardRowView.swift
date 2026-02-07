//
//  CardRowView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import SwiftUI

struct CardRowView: View {
    let card: FlashCard
    @Environment(CardStore.self) private var cardStore
    @State private var speechService = SpeechService()

    var body: some View {
        MujiCard(padding: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.japanese)
                        .font(.custom("Hiragino Sans", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primaryText)
                        .lineLimit(1)
                    
                    // Categories
                    let categories = cardStore.categories(for: card)
                    if !categories.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(categories.prefix(3)) { category in
                                Text(category.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(category.color.opacity(0.1))
                                    .foregroundColor(category.color)
                                    .cornerRadius(4)
                            }
                            
                            if categories.count > 3 {
                                Text("...")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }
                    } else {
                         // Placeholder to maintain height consistency if desired, or just empty
                         // For "Bottom-Left", if no category, just Japanese is fine?
                         // User said "Left Top Japanese, Left Bottom Category".
                         // If empty, maybe show nothing.
                    }
                }
                
                Spacer()
                
                Button {
                    speechService.speak(card.japanese)
                } label: {
                    Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .foregroundColor(AppTheme.Colors.accent)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    CardRowView(card: FlashCard(
        japanese: "こんにちは",
        translation: "你好",
        categoryIDs: []
    ))
    .environment(CardStore())
}
