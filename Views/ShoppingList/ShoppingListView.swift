import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel: ShoppingListViewModel
    @EnvironmentObject var groupViewModel: GroupViewModel
    @State private var showingAddItemSheet = false
    @State private var showingExpenseSummary = false
    @State private var filterByUser: String?
    @State private var searchText = ""
    
    init(groupID: String) {
        // This will be initialized properly in onAppear
        _viewModel = StateObject(wrappedValue: ShoppingListViewModel(groupID: groupID, authViewModel: AuthViewModel()))
    }
    
    var body: some View {
        VStack {
            // Filter controls
            HStack {
                TextField("Search items", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Menu {
                    Button("All Users") {
                        filterByUser = nil
                    }
                    
                    ForEach(getUniqueUsers(), id: \.self) { user in
                        Button(user) {
                            filterByUser = user
                        }
                    }
                } label: {
                    Label(
                        filterByUser ?? "All Users",
                        systemImage: "person.fill"
                    )
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Shopping list
            List {
                ForEach(filteredItems) { item in
                    ItemRowView(item: item, viewModel: viewModel)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteItem(filteredItems[index])
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.items.isEmpty {
                        VStack {
                            Image(systemName: "cart")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Your shopping list is empty")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Tap + to add items")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            )
        }
        .navigationTitle(groupViewModel.selectedGroup?.name ?? "Shopping List")
        .navigationBarItems(
            leading: Button(action: {
                showingExpenseSummary = true
            }) {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 20))
            },
            trailing: Button(action: {
                showingAddItemSheet = true
            }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingExpenseSummary) {
            ExpenseSummaryView(summary: viewModel.calculateExpenseSummary())
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            if let authViewModel = groupViewModel.authViewModel {
                viewModel.authViewModel = authViewModel
            }
        }
    }
    
    private var filteredItems: [Item] {
        viewModel.items.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            let matchesUser = filterByUser == nil || item.addedBy == filterByUser
            return matchesSearch && matchesUser
        }
    }
    
    private func getUniqueUsers() -> [String] {
        Array(Set(viewModel.items.map { $0.addedBy })).sorted()
    }
}
