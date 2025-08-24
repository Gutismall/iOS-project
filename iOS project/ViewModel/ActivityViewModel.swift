import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

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

    /// Fetch all activities from local GroupsViewModel groups, filter by groupIds,
    /// collect them, sort by timestamp, and publish to `activities`.
    func fetchActivities(for groupIds: [String]) {
        var collected = self.activities

        for group in GroupsViewModel.shared.groups where groupIds.contains(group.id) {
            collected.append(contentsOf: group.activities)
        }

        collected.sort { $0.timestamp.seconds < $1.timestamp.seconds }

        let result = collected   // capture-by-value before hopping to MainActor
        self.activities = result
    }
}
