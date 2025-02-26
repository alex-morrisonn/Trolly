import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var groupViewModel: GroupViewModel
    @State private var showingAddGroupSheet = false
    @State private var showingInviteSheet = false
    @State private var selectedGroupForInvite: Group?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupViewModel.groups) { group in
                    GroupRowView(group: group)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            groupViewModel.selectedGroup = group
                        }
                        .swipeActions {
                            if group.id != nil {
                                Button {
                                    selectedGroupForInvite = group
                                    showingInviteSheet = true
                                } label: {
                                    Label("Invite", systemImage: "person.badge.plus")
                                }
                                .tint(.blue)
                                
                                Button {
                                    if let id = group.id {
                                        groupViewModel.leaveGroup(groupID: id)
                                    }
                                } label: {
                                    Label("Leave", systemImage: "rectangle.portrait.and.arrow.forward")
                                }
                                .tint(.red)
                            }
                        }
                }
            }
            .navigationTitle("My Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGroupSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGroupSheet) {
                AddGroupView()
                    .environmentObject(groupViewModel)
            }
            .sheet(isPresented: $showingInviteSheet) {
                if let group = selectedGroupForInvite {
                    InviteToGroupView(group: group)
                        .environmentObject(groupViewModel)
                }
            }
            .overlay(
                Group {
                    if groupViewModel.isLoading {
                        ProgressView()
                    } else if groupViewModel.groups.isEmpty {
                        VStack {
                            Image(systemName: "person.3")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("You're not in any groups yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Tap + to create a new group")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            )
            .alert(item: Binding<AlertItem?>(
                get: { groupViewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in groupViewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

