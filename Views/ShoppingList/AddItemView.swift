import SwiftUI

struct AddItemView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var itemName = ""
    @State private var price: String = ""
    @State private var category = ""
    @State private var notes = ""
    
    private var categories = ["Produce", "Dairy", "Meat", "Bakery", "Frozen", "Pantry", "Household", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                    
                    TextField("Price (Optional)", text: $price)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        Text("None").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: addItem) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .navigationTitle("Add New Item")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addItem() {
        let priceValue = Double(price) ?? nil
        let categoryValue = category.isEmpty ? nil : category
        let notesValue = notes.isEmpty ? nil : notes
        
        viewModel.addItem(name: itemName, price: priceValue, category: categoryValue, notes: notesValue)
        presentationMode.wrappedValue.dismiss()
    }
}
