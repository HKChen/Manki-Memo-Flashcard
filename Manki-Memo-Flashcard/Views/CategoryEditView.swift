import SwiftUI

struct CategoryEditView: View {
    @Environment(CardStore.self) private var cardStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var color: Color
    
    private let existingCategory: Category?
    
    init(category: Category? = nil) {
        self.existingCategory = category
        _name = State(initialValue: category?.name ?? "")
        _color = State(initialValue: category?.color ?? .blue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("分類資訊") {
                    TextField("分類名稱", text: $name)
                    ColorPicker("代表色", selection: $color)
                }
            }
            .navigationTitle(existingCategory == nil ? "新增分類" : "編輯分類")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        if let existingCategory {
            var updatedCategory = existingCategory
            updatedCategory.name = name
            updatedCategory.color = color
            cardStore.updateCategory(updatedCategory)
        } else {
            // New category
            // We need to convert color to hex and init
            // Since our Category init takes hex, and we added a setter for color,
            // we can init with default and then set color.
            var newCategory = Category(name: name)
            newCategory.color = color
            cardStore.addCategory(newCategory)
        }
        dismiss()
    }
}

#Preview {
    CategoryEditView()
        .environment(CardStore())
}
