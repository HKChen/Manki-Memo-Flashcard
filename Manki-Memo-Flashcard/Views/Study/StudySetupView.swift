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
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Description
                        Text("選擇要練習的分類，這些分類中的字卡將會隨機出現。")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("分類選擇")
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(.horizontal)
                            
                            MujiCard(padding: 0) {
                                VStack(spacing: 0) {
                                    if store.categories.isEmpty {
                                        Text("尚無分類")
                                            .foregroundStyle(AppTheme.Colors.secondaryText)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        ForEach(Array(store.categories.enumerated()), id: \.element.id) { index, category in
                                            Toggle(isOn: Binding(
                                                get: { selectedCategories.contains(category.id) },
                                                set: { isSelected in
                                                    if isSelected {
                                                        selectedCategories.insert(category.id)
                                                    } else {
                                                        selectedCategories.remove(category.id)
                                                    }
                                                }
                                            )) {
                                                HStack {
                                                    Circle()
                                                        .fill(category.color)
                                                        .frame(width: 12, height: 12)
                                                    Text(category.name)
                                                        .foregroundColor(AppTheme.Colors.primaryText)
                                                }
                                            }
                                            .padding()
                                            .tint(AppTheme.Colors.accent)
                                            
                                            if index < store.categories.count - 1 || true { // Divider for all categories followed by uncategorized toggle
                                                Divider().padding(.leading)
                                            }
                                        }
                                    }
                                    
                                    if !store.categories.isEmpty {
                                        // No divider needed here if we put it above
                                    }
                                    
                                    Toggle("未分類字卡", isOn: $includeUncategorized)
                                        .padding()
                                        .tint(AppTheme.Colors.accent)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Draw Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("抽卡設定")
                                .font(.headline)
                                .foregroundColor(AppTheme.Colors.primaryText)
                                .padding(.horizontal)
                            
                            MujiCard(padding: 0) {
                                VStack(spacing: 0) {
                                    Toggle("設定抽卡數量", isOn: $isLimitEnabled)
                                        .padding()
                                        .tint(AppTheme.Colors.accent)
                                    
                                    if isLimitEnabled {
                                        Divider().padding(.leading)
                                        Stepper("數量: \(cardLimit)", value: $cardLimit, in: 5...100, step: 5)
                                            .padding()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Start Button
                        Button {
                            startSession()
                        } label: {
                            Text("開始抽卡")
                        }
                        .buttonStyle(MujiButtonStyle(isPrimary: true))
                        .disabled(selectedCategories.isEmpty && !includeUncategorized)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    .padding(.vertical)
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
