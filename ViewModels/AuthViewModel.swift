import Foundation
import Firebase
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let firebaseUser = firebaseUser {
                self.fetchUserData(userID: firebaseUser.uid)
            } else {
                self.user = nil
                self.isAuthenticated = false
            }
        }
    }
    
    func fetchUserData(userID: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self, error == nil else {
                self?.errorMessage = error?.localizedDescription
                return
            }
            
            if let data = snapshot?.data(), let user = try? Firestore.Decoder().decode(User.self, from: data) {
                DispatchQueue.main.async {
                    self.user = user
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let userID = result?.user.uid {
                let newUser = User(email: email, displayName: displayName)
                self.saveUserToFirestore(userID: userID, user: newUser)
            }
        }
    }
    
    func saveUserToFirestore(userID: String, user: User) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(userID).setData(from: user)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
