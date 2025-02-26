import SwiftUI

struct InviteToGroupView: View {
    let group: Group
    @EnvironmentObject var groupViewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Invite to \(group.name)")) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Button(action: sendInvite) {
                        Text("Send Invitation")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(email.isEmpty || !isValidEmail(email))
                }
                
                if !isValidEmail(email) && !email.isEmpty {
                    Section {
                        Text("Please enter a valid email address")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Invite Member")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func sendInvite() {
        if let groupID = group.id {
            groupViewModel.inviteUserToGroup(email: email, groupID: groupID)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
