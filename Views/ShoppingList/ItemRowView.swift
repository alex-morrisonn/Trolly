import SwiftUI

struct ItemRowView: View {
    let item: Item
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingItemDetail = false
    
    var body: some View {
        Button(action: {
            showingItemDetail = true
        }) {
            HStack {
                Button(action: {
                    viewModel.toggleItemChecked(item)
                }) {
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isChecked ? .green : .gray)
                }
                
                VStack(alignment: .leading) {
                    Text(item.name)
                        .strikethrough(item.isChecked)
                        .fontWeight(.medium)
                    
                    HStack {
                        if let price = item.price {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if let category = item.category, !category.isEmpty {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("by \(item.addedBy)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .fill(colorForUser(item.addedBy))
                            .frame(width: 10, height: 10)
                    }
                    
                    Text(relativeTime(for: item.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showingItemDetail) {
            ItemDetailView(item: item, viewModel: viewModel)
        }
    }
    
    private func colorForUser(_ username: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        let index = abs(username.hashValue) % colors.count
        return colors[index]
    }
    
    private func relativeTime(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

