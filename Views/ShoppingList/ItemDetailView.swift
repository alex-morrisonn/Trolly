import SwiftUI

struct ItemDetailView: View {
    @State var item: Item
    @ObservedObject var viewModel: ShoppingListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false
    
    // Editable fields
    @State private var editedName: String = ""
    @State private var editedPrice: String = ""
    @State private var editedCategory: String = ""
    @State private var editedNotes: String = ""
    
    private var categories = ["Produce", "Dairy", "Meat", "Bakery", "Frozen", "Pantry", "Household", "Other"]
    
    var body: some View {
        NavigationView {
            List {
                // Item details section
                Section(header: Text("Item Details")) {
                    if isEditing {
                        TextField("Item Name", text: $editedName)
                        
                        TextField("Price", text: $editedPrice)
                            .keyboardType(.decimalPad)
                        
                        Picker("Category", selection: $editedCategory) {
                            Text("None").tag("")
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        
                        TextEditor(text: $editedNotes)
                            .frame(minHeight: 100)
                    } else {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(item.name)
                                .foregroundColor(.secondary)
                        }
                        
                        if let price = item.price {
                            HStack {
                                Text("Price")
                                Spacer()
                                Text("$\(String(format: "%.2f", price))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let category = item.category, !category.isEmpty {
                            HStack {
                                Text("Category")
                                Spacer()
                                Text(category)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let notes = item.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                Text(notes)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                
                // Attribution section
                Section(header: Text("Added By")) {
                    HStack {
                        Circle()
                            .fill(colorForUser(item.addedBy))
                            .frame(width: 20, height: 20)
                        
                        Text(item.addedBy)
                        
                        Spacer()
                        
                        Text(formattedDate(item.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Edit history section
                Section(header: Text("Edit History")) {
                    if item.editHistory.isEmpty {
                        Text("No edit history")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(item.editHistory.sorted(by: { $0.timestamp > $1.timestamp }), id: \.timestamp) { edit in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(edit.action.capitalized)
                                        .font(.subheadline)
                                    
                                    Text("by \(edit.userName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(formattedDate(edit.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Delete button
                if !isEditing {
                    Section {
                        Button(action: {
                            viewModel.deleteItem(item)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Delete Item")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "Item Details")
            .navigationBarItems(
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        // Save changes
                        var updatedItem = item
                        updatedItem.name = editedName
                        updatedItem.price = Double(editedPrice)
                        updatedItem.category = editedCategory.isEmpty ? nil : editedCategory
                        updatedItem.notes = editedNotes.isEmpty ? nil : editedNotes
                        
                        viewModel.updateItem(updatedItem)
                        item = updatedItem
                        isEditing.toggle()
                    } else {
                        // Enter edit mode
                        editedName = item.name
                        editedPrice = item.price != nil ? String(format: "%.2f", item.price!) : ""
                        editedCategory = item.category ?? ""
                        editedNotes = item.notes ?? ""
                        isEditing.toggle()
                    }
                }
            )
        }
    }
    
    private func colorForUser(_ username: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        let index = abs(username.hashValue) % colors.count
        return colors[index]
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
