import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupViewModel: GroupViewModel
    
    init() {
        // This will be initialized with the authViewModel from the environment
        _groupViewModel = StateObject(wrappedValue: GroupViewModel(authViewModel: AuthViewModel()))
    }
    
    var body: some View {
        TabView {
            NavigationView {
                if let selectedGroup = groupViewModel.selectedGroup {
                    ShoppingListView(groupID: selectedGroup.id ?? "")
                        .environmentObject(groupViewModel)
                } else {
                    Text("Select or create a group to get started")
                }
            }
            .tabItem {
                Label("Shopping List", systemImage: "list.bullet")
            }
            
            GroupsView()
                .environmentObject(groupViewModel)
                .tabItem {
                    Label("Groups", systemImage: "person.3")
                }
            
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .onAppear {
            // Re-initialize with the correct authViewModel
            groupViewModel.authViewModel = authViewModel
        }
    }
}
