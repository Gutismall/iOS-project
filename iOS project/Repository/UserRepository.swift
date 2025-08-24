import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

final class UserRepository {
    private let db = Firestore.firestore()

    // MARK: - Public API
    @MainActor
    func fetchUser(userId: String) async throws -> User? {
        let userDocumentRef = db.collection("Users").document(userId)
        let userSnapshot = try await userDocumentRef.getDocument()
        guard let userData = userSnapshot.data() else { return nil }
        
        let invitesCollectionRef = userDocumentRef.collection("invites")
        let invitesSnapshot = try await invitesCollectionRef.getDocuments()
        let invites = parseInvites(invitesSnapshot.documents)
        
        return parseUser(userId: userId, data: userData, pendingInvites: invites)
    }
    // MARK: - Parsing

    // Parse user document data and invites into a User object.
    private func parseUser(userId: String, data: [String: Any], pendingInvites: [Invite]) -> User {
        let groupIds = data["groupIds"] as? [String] ?? []
        let monthlyBudget = data["monthlyBudget"] as? Int ?? 0
        let isFirstTime = data["isFirstTime"] as? Bool ?? true
        let photoURL = data["photoURL"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        
        return User(
            id: userId,
            groupIds: groupIds,
            monthlyBudget: monthlyBudget,
            photoURL: photoURL,
            email: email,
            name: name,
            isFirstTime: isFirstTime,
            pendingInvites: pendingInvites
        )
    }

    // Parse Firestore invite documents into Invite objects.
    private func parseInvites(_ inviteDocuments: [QueryDocumentSnapshot]) -> [Invite] {
        return inviteDocuments.compactMap { doc in
            let dict = doc.data()
            guard
                let id = dict["id"] as? String,
                let groupId = dict["groupId"] as? String,
                let inviterUid = dict["inviterUid"] as? String,
                let statusRaw = dict["status"] as? String,
                let createdAt = dict["createdAt"] as? Timestamp,
                let status = InviteStatus(rawValue: statusRaw)
            else {
                return nil
            }
            return Invite(
                id: id,
                groupId: groupId,
                inviterUid: inviterUid,
                status: status,
                createdAt: createdAt
            )
        }
    }
    
    func addGroupIdToUser(userId: String, groupId: String) async throws {
            let db = Firestore.firestore()
            let userRef = db.collection("Users").document(userId)
            let doc = try await userRef.getDocument()
            var remoteGroups = doc.data()?["groupIds"] as? [String] ?? []
            if !remoteGroups.contains(groupId) {
                remoteGroups.append(groupId)
                try await userRef.updateData(["groupIds": remoteGroups])
            }
        }
    
    func sendInvite(toEmail email: String, groupId: String) async throws {
        let db = Firestore.firestore()
        
        // 2) Look up target userId by email
        let query = try await db.collection("Users")
            .whereField("email", isEqualTo: email.lowercased())
            .limit(to: 1)
            .getDocuments()
        
        guard let doc = query.documents.first else {
            throw NSError(domain: "UserViewModel", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "No user found with that email."])
        }
        let targetUserId = doc.documentID
        
        // 3) Build invite payload
        let inviteId = UUID().uuidString
        let data: [String: Any] = [
            "id": inviteId,
            "groupId": groupId,
            "inviterUid": Auth.auth().currentUser!.uid,
            "status": "pending",              // keep in sync with your enum raw values
            "createdAt": Timestamp(date: Date())
        ]
        
        // 4) Write to recipient's subcollection
        try await db.collection("Users")
            .document(targetUserId)
            .collection("invites")
            .document(inviteId)
            .setData(data)
    }
    
    func setMonthlyBudget(budget: Int) async throws {
        let userRef = db.collection("Users").document(Auth.auth().currentUser?.uid ?? "")
        try await userRef.updateData([
            "monthlyBudget": budget
        ])
    }
    
    @MainActor
    func setUserIcon(image: Any) async throws -> String{
        let userId = Auth.auth().currentUser?.uid ?? ""
        let userRef = db.collection("Users").document(userId)
        
        if let image = image as? UIImage {
            let storageRef = Storage.storage().reference().child("userIcons/\(userId).png")
            do {
                try await storageRef.delete()
            } catch {
                let nsError = error as NSError
                // Ignore only "object not found" error
                if nsError.domain != StorageErrorDomain || nsError.code != StorageErrorCode.objectNotFound.rawValue {
                    throw error
                }
            }
            let imageToUpload = image.pngData()
            _ = try await storageRef.putDataAsync(imageToUpload!, metadata: nil)
            let url = try await storageRef.downloadURL().absoluteString
            try await userRef.updateData([
                "photoURL": url
            ])
            print("inside repository ",url)
            return url
        }
        else{
            try await userRef.updateData([
                "photoURL": image as! String
            ])
        }
        return ""
    }
    
    func updateUserData(data:[String:Any]) async throws{
        let userId = Auth.auth().currentUser?.uid ?? ""
        let userRef = db.collection("Users").document(userId)
        try await userRef.updateData(data)
    }
}
