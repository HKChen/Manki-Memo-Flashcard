//
//  CardListView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import SwiftUI

struct CardListView: View {
    @Environment(CardStore.self) private var cardStore
    @State private var searchText = ""

    var filteredCards: [FlashCard] {
        if searchText.isEmpty {
            return cardStore.cards
        } else {
            return cardStore.cards.filter { card in
                card.japanese.localizedCaseInsensitiveContains(searchText) ||
                card.translation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if cardStore.cards.isEmpty {
                    ContentUnavailableView {
                        Label("沒有字卡", systemImage: "rectangle.stack")
                    } description: {
                        Text("點擊下方「新增」來建立第一張字卡")
                    }
                } else if filteredCards.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredCards) { card in
                            NavigationLink(destination: CardDetailView(card: card)) {
                                CardRowView(card: card)
                            }
                        }
                        .onDelete(perform: cardStore.deleteCards)
                    }
                }
            }
            .navigationTitle("字卡列表")
            .searchable(text: $searchText, prompt: "搜尋字卡")
            .toolbar {
                EditButton()
            }
        }
    }
}

#Preview {
    CardListView()
        .environment(CardStore())
}
