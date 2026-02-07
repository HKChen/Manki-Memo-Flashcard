//
//  StudySetupView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/26.
//

import SwiftUI

struct StudySetupView: View {
    @Environment(CardStore.self) private var store
    
    @State private var selectedCategories: Set<UUID> = []
    @State private var includeUncategorized = false
    @State private var isLimitEnabled = false
    @State private var cardLimit = 10
    @State private var sessionWrapper: SessionData?
    @State private var showNoCardsAlert = false
    
    struct SessionData: Identifiable {
        let id = UUID()
        let cards: [FlashCard]
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("選擇要練習的分類，這些分類中的字卡將會隨機出現。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section(header: Text("分類選擇")) {
                    if store.categories.isEmpty {
                        Text("尚無分類")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.categories) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                
                                Toggle(category.name, isOn: Binding(
                                    get: { selectedCategories.contains(category.id) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedCategories.insert(category.id)
                                        } else {
                                            selectedCategories.remove(category.id)
                                        }
                                    }
                                ))
                            }
                        }
                    }
                    
                    Toggle("未分類字卡", isOn: $includeUncategorized)
                }

                Section(header: Text("抽卡設定")) {
                    Toggle("設定抽卡數量", isOn: $isLimitEnabled)
                    
                    if isLimitEnabled {
                        Stepper("數量: \(cardLimit)", value: $cardLimit, in: 5...100, step: 5)
                    }
                }
                
                Section {
                    Button {
                        startSession()
                    } label: {
                        HStack {
                            Spacer()
                            Text("開始抽卡")
                                .font(.headline)
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(selectedCategories.isEmpty && !includeUncategorized)
                }
            }
            .navigationTitle("抽卡設定")
            .fullScreenCover(item: $sessionWrapper) { wrapper in
                StudySessionView(cards: wrapper.cards)
            }
            .alert("沒有符合的字卡", isPresented: $showNoCardsAlert) {
                Button("好", role: .cancel) { }
            } message: {
                Text("請選擇其他分類或新增字卡。")
            }
        }
    }
    
    private func startSession() {
        var cardsToStudy: [FlashCard] = []
        
        let selectedSet = selectedCategories
        
        cardsToStudy = store.cards.filter { card in
            // handling uncategorized
            if card.categoryIDs.isEmpty {
                return includeUncategorized
            }
            
            // handling categorized
            // check if card has any category in the selected set
            let cardCategories = Set(card.categoryIDs)
            return !selectedSet.isDisjoint(with: cardCategories)
        }
        
        if cardsToStudy.isEmpty {
            showNoCardsAlert = true
        } else {
            var shuffledCards = cardsToStudy.shuffled()
            if isLimitEnabled {
                let limit = min(cardLimit, shuffledCards.count)
                shuffledCards = Array(shuffledCards.prefix(limit))
            }
            sessionWrapper = SessionData(cards: shuffledCards)
        }
    }
}

#Preview {
    StudySetupView()
        .environment(CardStore())
}
