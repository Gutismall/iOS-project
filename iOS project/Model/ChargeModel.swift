import Foundation
import FirebaseFirestore

struct Charge {
    var id: String
    var amount: Double
    var description: String
    var createdByName: String
    var category: ChargeCategory
    var timestamp: Timestamp
}
