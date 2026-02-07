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
            ZStack {
            AppTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {

                        
                        // Japanese
                        VStack(alignment: .leading, spacing: 8) {
                            Text("日文")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.leading, 4)
                            
                            MujiCard(padding: 0) {
                                HStack {
                                    TextField("輸入日文", text: $japanese)
                                        .focused($isInputActive)
                                        .padding()
                                    
                                    Button {
                                        speechService.speak(japanese)
                                    } label: {
                                        Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                            .foregroundColor(AppTheme.Colors.accent)
                                            .padding()
                                    }
                                    .disabled(japanese.isEmpty)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Translation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("翻譯")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.leading, 4)
                            
                            MujiCard(padding: 0) {
                                TextField("輸入中文翻譯", text: $translation)
                                    .focused($isInputActive)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("分類")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.leading, 4)
                            
                            MujiCard(padding: 0) {
                                Button {
                                    showingCategorySheet = true
                                } label: {
                                    HStack {
                                        Text("選擇分類")
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                        Spacer()
                                        if selectedCategoryIDs.isEmpty {
                                            Text("無")
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                        } else {
                                            Text("\(selectedCategoryIDs.count) 個分類")
                                                .foregroundColor(AppTheme.Colors.accent)
                                        }
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .imageScale(.small)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("備註")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .padding(.leading, 4)
                            
                            MujiCard(padding: 0) {
                                TextEditor(text: $notes)
                                    .focused($isInputActive)
                                    .frame(minHeight: 100)
                                    .padding(4) // TextEditor has some internal padding
                            }
                        }
                        .padding(.horizontal)

                        // Save Button
                        Button {
                            saveCard()
                        } label: {
                            Text("儲存字卡")
                        }
                        .buttonStyle(MujiButtonStyle(isPrimary: true))
                        .disabled(japanese.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("新增字卡")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("返回") {
                        tabSelection = 0
                    }
                    .tint(AppTheme.Colors.accent)
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
