import Foundation
import FirebaseCore

struct Activity: Hashable {
    let id: String
    let chargeId: String
    let prefomedBy: String
    let type: ActivityType
    let timestamp: Timestamp

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


enum ActivityType: String, Codable {
    case addCharge = "added charge"
    case removeCharge = "removed charge"
    case editCharge = "edited charge"
    case joinGroup = "joined a group"
    case leaveGroup = "left a group"
    case groupCreated = "creted a group"
}
