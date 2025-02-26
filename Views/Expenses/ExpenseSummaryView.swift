import SwiftUI

// Add model definition here
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

struct ExpenseSummaryView: View {
    let summary: ExpenseSummary
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Total Expenses")) {
                    HStack {
                        Text("Total Amount")
                        Spacer()
                        Text("$\(String(format: "%.2f", summary.totalAmount))")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Split Per Person")
                        Spacer()
                        Text("$\(String(format: "%.2f", summary.splitAmount))")
                            .fontWeight(.bold)
                    }
                }
                
                Section(header: Text("Contributions")) {
                    ForEach(summary.userContributions, id: \.userID) { contribution in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(contribution.userName)
                                
                                Text("\(contribution.itemCount) items")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$\(String(format: "%.2f", contribution.amount))")
                                    .font(.headline)
                                
                                HStack {
                                    if contribution.balance > 0 {
                                        Text("receives $\(String(format: "%.2f", contribution.balance))")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    } else if contribution.balance < 0 {
                                        Text("owes $\(String(format: "%.2f", abs(contribution.balance)))")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    } else {
                                        Text("settled")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button(action: {
                        // Share expense summary (implementation would connect to payment apps)
                        let message = createShareMessage()
                        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                        
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = scene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Summary")
                        }
                    }
                }
            }
            .navigationTitle("Expense Summary")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func createShareMessage() -> String {
        var message = "Trolly Shopping Expense Summary\n\n"
        message += "Total: $\(String(format: "%.2f", summary.totalAmount))\n"
        message += "Split per person: $\(String(format: "%.2f", summary.splitAmount))\n\n"
        message += "Contributions:\n"
        
        for contribution in summary.userContributions {
            message += "\(contribution.userName): $\(String(format: "%.2f", contribution.amount))"
            
            if contribution.balance > 0 {
                message += " (receives $\(String(format: "%.2f", contribution.balance)))"
            } else if contribution.balance < 0 {
                message += " (owes $\(String(format: "%.2f", abs(contribution.balance))))"
            } else {
                message += " (settled)"
            }
            
            message += "\n"
        }
        
        return message
    }
}
