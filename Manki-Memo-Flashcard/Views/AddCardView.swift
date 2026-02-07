//
//  AddCardView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/20.
//

import SwiftUI

struct AddCardView: View {
    @Environment(CardStore.self) private var cardStore
    @Binding var tabSelection: Int
    @State private var speechService = SpeechService()
    @FocusState private var isInputActive: Bool

    @State private var japanese: String = ""
    @State private var translation: String = ""
    @State private var notes: String = ""
    @State private var selectedCategoryIDs: [UUID] = []
    @State private var showingCategorySheet: Bool = false
    @State private var showingSaveAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("日文")) {
                    HStack {
                        TextField("輸入日文", text: $japanese)
                            .focused($isInputActive)

                        Button {
                            speechService.speak(japanese)
                        } label: {
                            Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(japanese.isEmpty)
                    }
                }



                Section(header: Text("翻譯")) {
                    TextField("輸入中文翻譯", text: $translation)
                        .focused($isInputActive)
                }

                Section(header: Text("分類")) {
                    Button {
                        showingCategorySheet = true
                    } label: {
                        HStack {
                            Text("選擇分類")
                            Spacer()
                            if selectedCategoryIDs.isEmpty {
                                Text("無")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(selectedCategoryIDs.count) 個分類")
                                    .foregroundColor(.blue)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .imageScale(.small)
                        }
                    }
                }

                Section(header: Text("備註")) {
                    TextEditor(text: $notes)
                        .focused($isInputActive)
                        .frame(minHeight: 100)
                }

                Section {
                    Button {
                        saveCard()
                    } label: {
                        HStack {
                            Spacer()
                            Text("儲存字卡")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(japanese.isEmpty)
                }
            }
            .navigationTitle("新增字卡")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("返回") {
                        tabSelection = 0
                    }
                }
            }
            .alert("儲存成功", isPresented: $showingSaveAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("字卡已成功儲存！")
            }
            .sheet(isPresented: $showingCategorySheet) {
                CategorySelectionView(selectedCategoryIDs: $selectedCategoryIDs)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func saveCard() {
        let card = FlashCard(
            japanese: japanese,
            translation: translation,
            notes: notes,
            categoryIDs: selectedCategoryIDs
        )
        cardStore.addCard(card)

        japanese = ""
        translation = ""
        notes = ""
        selectedCategoryIDs = []

        showingSaveAlert = true
    }
}

#Preview {
    AddCardView(tabSelection: .constant(1))
        .environment(CardStore())
}
