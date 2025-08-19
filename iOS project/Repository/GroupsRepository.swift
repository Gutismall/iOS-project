import Foundation
import FirebaseAuth
import FirebaseFirestore

final class GroupsRepository {
    private let db = Firestore.firestore()
    public init() {}

    // MARK: - Public API

    /// One-shot fetch of the user's groups (including charges & activities)
    @MainActor
    func fetchGroups(groupIds: [String]) async throws -> [Group] {
        
        let query = db.collection("Groups").whereField(FieldPath.documentID(), in: groupIds)
        let snapshot = try await query.getDocuments()

        return try await withThrowingTaskGroup(of: Group.self) { group in
            for doc in snapshot.documents {
                group.addTask { [weak self] in
                    guard let self = self
                    else {
                        throw NSError(domain: "GroupsRepository", code: -1)
                    }
                    return try await self.buildGroup(from: doc)
                }
            }
            var results: [Group] = []
            for try await g in group {
                results.append(g)
            }
            return results
        }
    }

    /// Create a new group with the current user as the first member
    func createGroup(name: String, icon: String) async throws -> Group {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "GroupsRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        let groupRef = db.collection("Groups").document()
        let groupId = groupRef.documentID
        let members: [String] = [user.uid]

        try await groupRef.setData([
            "name": name,
            "image": icon,
            "members": members
        ])
        return Group(
            id: groupId,
            name: name,
            members: members,
            groupIcon: icon,
            activities: [],
            charges: []
        )
    }

    /// Add a new charge to a group (id is expected to be pre-generated)
    func addChargeToGroup(charge: Charge, groupId: String) async throws {
        let data: [String: Any] = [
            "amount": charge.amount,
            "description": charge.description,
            "createdByName": charge.createdByName,
            "category": charge.category.rawValue,
            "timestamp": charge.timestamp
        ]
        try await db.collection("Groups").document(groupId)
            .collection("charges").document(charge.id)
            .setData(data)
    }

    /// Add a new activity to a group (id is expected to be pre-generated)
    func addActivityToGroup(groupId: String, activity: Activity) async throws {
        let data: [String: Any] = [
            "chargeId": activity.chargeId,
            "prefomedBy": activity.prefomedBy,
            "type": activity.type.rawValue,
            "timestamp": activity.timestamp
        ]
        try await db.collection("Groups").document(groupId)
            .collection("activities").document(activity.id)
            .setData(data)
    }

    // MARK: - Helpers

    /// Build a full `Group` (including subcollections) from a group document
    private func buildGroup(from doc: QueryDocumentSnapshot) async throws -> Group {
        let data = doc.data()
        let id = doc.documentID
        let name = data["name"] as? String ?? ""
        let groupIcon = data["image"] as? String ?? ""
        let members: [String] = data["members"] as? [String] ?? []

        async let charges: [Charge] = {
            let snap = try await db.collection("Groups").document(id).collection("charges").getDocuments()
            return snap.documents.compactMap { d in
                let cd = d.data()
                guard let amount = cd["amount"] as? Double,
                      let desc = cd["description"] as? String,
                      let createdByName = cd["createdByName"] as? String,
                      let categoryRaw = cd["category"] as? String,
                      let category = ChargeCategory(rawValue: categoryRaw),
                      let timestamp = cd["timestamp"] as? Timestamp else { return nil }
                return Charge(id: d.documentID, amount: amount, description: desc, createdByName: createdByName, category: category, timestamp: timestamp)
            }
        }()

        async let activities: [Activity] = {
            let snap = try await db.collection("Groups").document(id).collection("activities").order(by: "timestamp", descending: true).getDocuments()
            return snap.documents.compactMap { d in
                let ad = d.data()
                guard let chargeId = ad["chargeId"] as? String,
                      let prefomedBy = ad["prefomedBy"] as? String,
                      let typeRaw = ad["type"] as? String,
                      let type = ActivityType(rawValue: typeRaw),
                      let timestamp = ad["timestamp"] as? Timestamp
                else {
                    return nil
                }
                return Activity(id: d.documentID, chargeId: chargeId, prefomedBy: prefomedBy, type: type, timestamp: timestamp)
            }
        }()

        return Group(id: id, name: name, members: members, groupIcon: groupIcon, activities: try await activities, charges: try await charges)
    }
    
    func removeChargeFromGroup(charge: Charge, groupId: String) async throws {
        let chargeRef = db.collection("Groups")
            .document(groupId)
            .collection("charges")
            .document(charge.id)
        try await chargeRef.delete()
    }
}
