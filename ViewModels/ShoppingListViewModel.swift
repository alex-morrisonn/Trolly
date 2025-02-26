import Foundation
import Firebase
import FirebaseFirestore
import Combine

class ShoppingListViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var groupID: String
    private var authViewModel: AuthViewModel
    
    init(groupID: String, authViewModel: AuthViewModel) {
        self.groupID = groupID
        self.authViewModel = authViewModel
        fetchItems()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchItems() {
        isLoading = true
        
        listenerRegistration = db.collection("groups").document(groupID).collection("items")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No documents found"
                    return
                }
                
                self.items = documents.compactMap { document in
                    try? document.data(as: Item.self)
                }
            }
    }
    
    func addItem(name: String, price: Double?, category: String? = nil, notes: String? = nil) {
        guard let user = authViewModel.user else {
            errorMessage = "User not authenticated"
            return
        }
        
        let newItem = Item(
            name: name,
            addedBy: user.displayName,
            userID: user.id ?? "",
            timestamp: Date(),
            price: price,
            category: category,
            notes: notes,
            editHistory: [
                EditRecord(
                    userID: user.id ?? "",
                    userName: user.displayName,
                    timestamp: Date(),
                    action: "added"
                )
            ]
        )
        
        do {
            let _ = try db.collection("groups").document(groupID).collection("items").addDocument(from: newItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateItem(_ item: Item) {
        guard let id = item.id, let user = authViewModel.user else { return }
        
        // Add edit record
        var updatedItem = item
        let editRecord = EditRecord(
            userID: user.id ?? "",
            userName: user.displayName,
            timestamp: Date(),
            action: "edited"
        )
        updatedItem.editHistory.append(editRecord)
        
        do {
            try db.collection("groups").document(groupID).collection("items").document(id).setData(from: updatedItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleItemChecked(_ item: Item) {
        guard let id = item.id else { return }
        
        var updatedItem = item
        updatedItem.isChecked.toggle()
        
        updateItem(updatedItem)
    }
    
    func deleteItem(_ item: Item) {
        guard let id = item.id else { return }
        
        db.collection("groups").document(groupID).collection("items").document(id).delete { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func calculateExpenseSummary() -> ExpenseSummary {
        var userContributions: [String: UserContribution] = [:]
        var totalAmount: Double = 0
        
        for item in items {
            guard let price = item.price else { continue }
            totalAmount += price
            
            if let contribution = userContributions[item.userID] {
                var updatedContribution = contribution
                updatedContribution.amount += price
                updatedContribution.itemCount += 1
                userContributions[item.userID] = updatedContribution
            } else {
                userContributions[item.userID] = UserContribution(
                    userID: item.userID,
                    userName: item.addedBy,
                    amount: price,
                    itemCount: 1
                )
            }
        }
        
        let contributionArray = Array(userContributions.values)
        let splitAmount = contributionArray.isEmpty ? 0 : totalAmount / Double(contributionArray.count)
        
        // Calculate balances
        var balancedContributions = contributionArray
        for i in 0..<balancedContributions.count {
            balancedContributions[i].balance = balancedContributions[i].amount - splitAmount
        }
        
        return ExpenseSummary(totalAmount: totalAmount, userContributions: balancedContributions)
    }
}
