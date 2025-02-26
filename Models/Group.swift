import Foundation
import FirebaseFirestore

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var createdBy: String
    var members: [GroupMember] = []
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, createdBy, members, createdAt
    }
}

struct GroupMember: Codable {
    var userID: String
    var role: MemberRole
    var joinedAt: Date
}

enum MemberRole: String, Codable {
    case admin
    case editor
    case viewer
}
