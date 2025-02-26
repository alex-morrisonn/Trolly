import SwiftUI

struct AddGroupView: View {
    @EnvironmentObject var groupViewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName = ""
    @State private var groupDescription = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Details")) {
                    TextField("Group Name", text: $groupName)
                    TextField("Description (Optional)", text: $groupDescription)
                }
                
                Section {
                    Button(action: createGroup) {
                        Text("Create Group")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(groupName.isEmpty)
                }
            }
            .navigationTitle("Create New Group")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func createGroup() {
        let description = groupDescription.isEmpty ? nil : groupDescription
        groupViewModel.createGroup(name: groupName, description: description)
        presentationMode.wrappedValue.dismiss()
    }
}
