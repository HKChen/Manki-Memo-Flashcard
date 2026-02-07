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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.japanese)
                    .font(.headline)

                Text(card.translation)
                    .font(.subheadline)
                    .foregroundColor(.blue)

                let categories = cardStore.categories(for: card)
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(categories.prefix(3)) { category in
                                Text(category.name)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(category.color.opacity(0.2))
                                    .foregroundColor(category.color)
                                    .cornerRadius(4)
                            }
                            
                            if categories.count > 3 {
                                Text("...")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            Button {
                speechService.speak(card.japanese)
            } label: {
                Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
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
