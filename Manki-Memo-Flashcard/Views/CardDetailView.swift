//
//  CardDetailView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(CardStore.self) private var cardStore
    @State private var speechService = SpeechService()
    @Environment(\.dismiss) private var dismiss

    let card: FlashCard

    @State private var isEditing: Bool = false
    @State private var editedJapanese: String = ""
    @State private var editedTranslation: String = ""
    @State private var editedNotes: String = ""
    @State private var editedCategoryIDs: [UUID] = []
    @State private var showingCategorySheet: Bool = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Japanese Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日文")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.horizontal)
                        
                        MujiCard(padding: 0) {
                            if isEditing {
                                TextField("日文", text: $editedJapanese)
                                    .padding()
                            } else {
                                HStack {
                                    Text(card.japanese)
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppTheme.Colors.primaryText)
                                    Spacer()
                                    speakButton(text: card.japanese)
                                }
                                .padding()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Translation Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("翻譯")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.horizontal)
                        
                        MujiCard(padding: 0) {
                            if isEditing {
                                TextField("翻譯", text: $editedTranslation)
                                    .padding()
                            } else {
                                Text(card.translation)
                                    .foregroundColor(AppTheme.Colors.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("分類")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.horizontal)
                        
                        MujiCard(padding: 0) {
                            if isEditing {
                                Button {
                                    showingCategorySheet = true
                                } label: {
                                    HStack {
                                        Text("選擇分類")
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                        Spacer()
                                        if editedCategoryIDs.isEmpty {
                                            Text("無")
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                        } else {
                                            Text("\(editedCategoryIDs.count) 個分類")
                                                .foregroundColor(AppTheme.Colors.accent)
                                        }
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .imageScale(.small)
                                    }
                                    .padding()
                                }
                            } else {
                                let categories = cardStore.categories(for: card)
                                if categories.isEmpty {
                                    Text("無分類")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(categories) { category in
                                                Text(category.name)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(category.color.opacity(0.1))
                                                    .foregroundColor(category.color)
                                                    .cornerRadius(4)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("備註")
                            .font(.headline)
                            .foregroundColor(AppTheme.Colors.primaryText)
                            .padding(.horizontal)
                        
                        MujiCard(padding: 0) {
                            if isEditing {
                                TextEditor(text: $editedNotes)
                                    .frame(minHeight: 100)
                                    .padding(4)
                            } else {
                                Text(card.notes.isEmpty ? "-" : card.notes)
                                    .foregroundColor(card.notes.isEmpty ? AppTheme.Colors.secondaryText : AppTheme.Colors.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !isEditing {
                        // Metadata
                         VStack(alignment: .leading, spacing: 8) {
                            Text("建立時間：\(card.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.horizontal)
                         }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(isEditing ? "編輯字卡" : "字卡詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "儲存" : "編輯") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
                .tint(AppTheme.Colors.accent)
                .disabled(isEditing && editedJapanese.isEmpty)
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isEditing = false
                    }
                    .tint(AppTheme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingCategorySheet) {
            CategorySelectionView(selectedCategoryIDs: $editedCategoryIDs)
                .presentationDetents([.medium, .large])
        }
    }

    private func speakButton(text: String) -> some View {
        Button {
            speechService.speak(text)
        } label: {
            Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                .foregroundColor(.blue)
        }
        .buttonStyle(.borderless)
    }

    private func startEditing() {
        editedJapanese = card.japanese
        editedTranslation = card.translation
        editedNotes = card.notes
        editedCategoryIDs = card.categoryIDs
        isEditing = true
    }

    private func saveChanges() {
        var updatedCard = card
        updatedCard.japanese = editedJapanese
        updatedCard.translation = editedTranslation
        updatedCard.notes = editedNotes
        updatedCard.categoryIDs = editedCategoryIDs

        cardStore.updateCard(updatedCard)
        isEditing = false
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: FlashCard(
            // りしれこんさ小
            japanese: "りしれこんさ小",
            // こんにちは
            translation: "你好",
            notes: "基本問候語",
            categoryIDs: []
        ))
        .environment(CardStore())
    }
}
