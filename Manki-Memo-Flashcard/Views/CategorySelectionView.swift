//
//  CategorySelectionView.swift
//  Manki-Memo-Flashcard
//
//  Created by hk on 2026/1/25.
//

import SwiftUI

struct CategorySelectionView: View {
    @Environment(CardStore.self) private var cardStore
    @Binding var selectedCategoryIDs: [UUID]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(cardStore.categories) { category in
                    Button {
                        toggleSelection(for: category)
                    } label: {
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 10, height: 10)
                            Text(category.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedCategoryIDs.contains(category.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("選擇分類")
            .toolbar {
                Button("完成") {
                    dismiss()
                }
            }
            .overlay {
                if cardStore.categories.isEmpty {
                    ContentUnavailableView {
                        Label("尚無分類", systemImage: "tag.slash")
                    } description: {
                        Text("請至「分類」頁籤新增分類")
                    }
                }
            }
        }
    }

    private func toggleSelection(for category: Category) {
        if let index = selectedCategoryIDs.firstIndex(of: category.id) {
            selectedCategoryIDs.remove(at: index)
        } else {
            selectedCategoryIDs.append(category.id)
        }
    }
}

#Preview {
    CategorySelectionView(selectedCategoryIDs: .constant([]))
        .environment(CardStore())
}
