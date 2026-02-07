//
//  CategoryListView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(CardStore.self) private var cardStore
    @State private var showingAddSheet = false
    @State private var categoryToEdit: Category?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background.ignoresSafeArea()
                
                if cardStore.categories.isEmpty {
                    ContentUnavailableView {
                        Label("沒有分類", systemImage: "tag.slash")
                    } description: {
                        Text("點擊右上角「+」來建立第一個分類")
                    }
                } else {
                    List {
                        ForEach(cardStore.categories) { category in
                            MujiCard(padding: 12) {
                                Button {
                                    categoryToEdit = category
                                } label: {
                                    HStack {
                                        Circle()
                                            .fill(category.color)
                                            .frame(width: 12, height: 12)
                                        Text(category.name)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.Colors.primaryText)
                                        Spacer()
                                        Image(systemName: "pencil")
                                            .foregroundColor(AppTheme.Colors.secondaryText)
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: cardStore.deleteCategories)
                    }
                    .listStyle(.plain)
                    .background(AppTheme.Colors.background)
                }
            }
            .navigationTitle("分類管理")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .tint(AppTheme.Colors.accent)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                CategoryEditView()
                    .presentationDetents([.medium])
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryEditView(category: category)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    CategoryListView()
        .environment(CardStore())
}
