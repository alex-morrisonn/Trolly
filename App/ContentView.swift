import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { authViewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in authViewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct AlertItem: Identifiable {
    var id = UUID()
    var message: String
}
