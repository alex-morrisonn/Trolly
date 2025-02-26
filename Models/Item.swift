import Foundation
import FirebaseFirestore

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var isChecked: Bool = false
    var addedBy: String
    var userID: String
    var timestamp: Date
    var price: Double?
    var category: String?
    var notes: String?
    var editHistory: [EditRecord] = []
    
    enum CodingKeys: String, CodingKey {
        case id, name, isChecked, addedBy, userID, timestamp, price, category, notes, editHistory
    }
}

struct EditRecord: Codable {
    var userID: String
    var userName: String
    var timestamp: Date
    var action: String // "added", "edited", "removed", etc.
}
