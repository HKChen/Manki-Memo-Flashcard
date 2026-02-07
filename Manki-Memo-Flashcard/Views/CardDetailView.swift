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
        Form {
            Section(header: Text("日文")) {
                if isEditing {
                    TextField("日文", text: $editedJapanese)
                } else {
                    HStack {
                        Text(card.japanese)
                            .font(.title2)
                        Spacer()
                        speakButton(text: card.japanese)
                    }
                }
            }

            Section(header: Text("分類")) {
                if isEditing {
                    Button {
                        showingCategorySheet = true
                    } label: {
                        HStack {
                            Text("選擇分類")
                            Spacer()
                            if editedCategoryIDs.isEmpty {
                                Text("無")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(editedCategoryIDs.count) 個分類")
                                    .foregroundColor(.blue)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .imageScale(.small)
                        }
                    }
                } else {
                    let categories = cardStore.categories(for: card)
                    if categories.isEmpty {
                        Text("無分類")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(categories) { category in
                                    Text(category.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(category.color.opacity(0.2))
                                        .foregroundColor(category.color)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }



            Section(header: Text("翻譯 TODO")) {
//                if isEditing {
//                    TextField("翻譯", text: $editedTranslation)
//                } else {
//                    Text(card.translation)
//                }
            }

            Section(header: Text("備註")) {
                if isEditing {
                    TextEditor(text: $editedNotes)
                        .frame(minHeight: 100)
                } else {
                    Text(card.notes.isEmpty ? "-" : card.notes)
                        .foregroundColor(card.notes.isEmpty ? .secondary : .primary)
                }
            }

            if !isEditing {
                Section(header: Text("發音選項")) {
                    ForEach(SpeechRate.allCases, id: \.self) { rate in
                        Button {
                            speechService.speak(card.japanese, rate: rate)
                        } label: {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                Text(rate.displayName)
                                Spacer()
                                if speechService.isSpeaking {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }

                Section {
                    Text("建立時間：\(card.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
                .disabled(isEditing && editedJapanese.isEmpty)
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isEditing = false
                    }
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
