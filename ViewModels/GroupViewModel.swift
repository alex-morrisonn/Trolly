import Foundation
import Firebase
import FirebaseFirestore
import Combine

class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var selectedGroup: Group?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        fetchGroups()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchGroups() {
        guard let userID = authViewModel.user?.id else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        
        listenerRegistration = db.collection("groups")
            .whereField("members.userID", arrayContains: userID)
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
                
                self.groups = documents.compactMap { document in
                    try? document.data(as: Group.self)
                }
                
                if self.selectedGroup == nil && !self.groups.isEmpty {
                    self.selectedGroup = self.groups.first
                }
            }
    }
    
    func createGroup(name: String, description: String?) {
        guard let user = authViewModel.user, let userID = user.id else {
            errorMessage = "User not authenticated"
            return
        }
        
        let newGroup = Group(
            name: name,
            description: description,
            createdBy: userID,
            members: [
                GroupMember(
                    userID: userID,
                    role: .admin,
                    joinedAt: Date()
                )
            ],
            createdAt: Date()
        )
        
        do {
            let documentRef = try db.collection("groups").addDocument(from: newGroup)
            
            // Update user's groups array
            if let userID = user.id {
                db.collection("users").document(userID).updateData([
                    "groups": FieldValue.arrayUnion([documentRef.documentID])
                ])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func inviteUserToGroup(email: String, groupID: String) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let documents = snapshot?.documents, let document = documents.first else {
                self.errorMessage = "User not found"
                return
            }
            
            if let invitedUserID = document.documentID as? String {
                let groupRef = self.db.collection("groups").document(groupID)
                
                // Check if user already in group
                groupRef.getDocument { snapshot, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let groupData = snapshot?.data(),
                          let members = groupData["members"] as? [[String: Any]] else {
                        self.errorMessage = "Failed to retrieve group data"
                        return
                    }
                    
                    // Check if user already in members array
                    let isAlreadyMember = members.contains { member in
                        return (member["userID"] as? String) == invitedUserID
                    }
                    
                    if !isAlreadyMember {
                        // Add user to group
                        let newMember: [String: Any] = [
                            "userID": invitedUserID,
                            "role": MemberRole.editor.rawValue,
                            "joinedAt": Timestamp(date: Date())
                        ]
                        
                        groupRef.updateData([
                            "members": FieldValue.arrayUnion([newMember])
                        ])
                        
                        // Add group to user's groups array
                        self.db.collection("users").document(invitedUserID).updateData([
                            "groups": FieldValue.arrayUnion([groupID])
                        ])
                    } else {
                        self.errorMessage = "User is already a member of this group"
                    }
                }
            }
        }
    }
    
    func leaveGroup(groupID: String) {
        guard let userID = authViewModel.user?.id else {
            errorMessage = "User not authenticated"
            return
        }
        
        let groupRef = db.collection("groups").document(groupID)
        
        // Get current group data
        groupRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard var group = try? snapshot?.data(as: Group.self) else {
                self.errorMessage = "Failed to retrieve group data"
                return
            }
            
            // Remove user from members array
            group.members.removeAll { $0.userID == userID }
            
            // If group now has no members, delete the group
            if group.members.isEmpty {
                groupRef.delete()
            } else {
                // Otherwise update group with new members array
                try? groupRef.setData(from: group)
            }
            
            // Remove group from user's groups array
            db.collection("users").document(userID).updateData([
                "groups": FieldValue.arrayRemove([groupID])
            ])
            
            // Update selected group if needed
            if self.selectedGroup?.id == groupID {
                self.selectedGroup = self.groups.first(where: { $0.id != groupID })
            }
        }
    }
}
