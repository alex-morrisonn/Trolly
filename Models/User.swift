import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var photoURL: String?
    var groups: [String] = [] // IDs of groups user belongs to
    
    enum CodingKeys: String, CodingKey {
        case id, email, displayName, photoURL, groups
    }
}
