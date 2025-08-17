import Foundation
import FirebaseAuth
import FirebaseCore

struct ActivityBuilder {
    var id: String = UUID().uuidString
    var chargeId: String? = ""
    var performedBy: String = Auth.auth().currentUser?.displayName ?? ""
    var type: ActivityType = .addCharge
    var timestamp: Timestamp = Timestamp(date: Date())

    func build() -> Activity {
        return Activity(
            id: id,
            chargeId: chargeId ?? "",
            prefomedBy: performedBy,
            type: type,
            timestamp: timestamp
        )
    }
}

class ActivityViewModel: ObservableObject {
    static var shared = ActivityViewModel()

    @Published private(set) var activities: [Activity] = []

    private init() {}

    static func resetShared() {
        shared = ActivityViewModel()
    }

    func resetState() {
        activities.removeAll()
    }
    
    func setActivities(activities:[Activity]){
        self.activities = activities
    }

    // Builder usage example
    func buildActivity(chargeId: String? = "", type: ActivityType) -> Activity {
        var builder = ActivityBuilder()
        builder.id = UUID().uuidString
        builder.chargeId = chargeId
        builder.performedBy = Auth.auth().currentUser?.displayName ?? ""
        builder.type = type
        builder.timestamp = Timestamp(date: Date())
        return builder.build()
    }
    
    
}
