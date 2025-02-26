import Foundation

struct ExpenseSummary {
    var totalAmount: Double
    var userContributions: [UserContribution]
    var splitAmount: Double {
        return userContributions.isEmpty ? 0 : totalAmount / Double(userContributions.count)
    }
}

struct UserContribution {
    var userID: String
    var userName: String
    var amount: Double
    var itemCount: Int
    
    var balance: Double = 0 // Positive means they are owed money, negative means they owe
}
