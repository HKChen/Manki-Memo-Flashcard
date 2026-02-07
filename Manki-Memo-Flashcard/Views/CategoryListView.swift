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
            List {
                ForEach(cardStore.categories) { category in
                    Button {
                        categoryToEdit = category
                    } label: {
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 12, height: 12)
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: cardStore.deleteCategories)
            }
            .navigationTitle("分類管理")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                CategoryEditView()
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryEditView(category: category)
            }
            .overlay {
                if cardStore.categories.isEmpty {
                    ContentUnavailableView {
                        Label("沒有分類", systemImage: "tag.slash")
                    } description: {
                        Text("點擊右上角「+」來建立第一個分類")
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryListView()
        .environment(CardStore())
}
