import Foundation
import FirebaseFirestore

final class UserViewModel: ObservableObject {
    static var shared = UserViewModel()
    
    @Published private(set) var user: User!
    private let userRepository = UserRepository()
    
    private init() {
        
    }
    
    func setUser(user:User){
        self.user = user
    }
    
    // New session: fresh instance
    static func resetShared() {
        shared = UserViewModel()
    }
    
    // Logout: clear state on current instance
    func resetState() {
        user = nil
    }
    
    @MainActor
    func fetchUser(userId:String) async -> User{
        return try! await self.userRepository.fetchUser(userId: userId)!
    }
    
    func sendInvite(toEmail email: String, groupId: String) async throws {
        try await self.userRepository.sendInvite(toEmail: email, groupId: groupId)
    }
    
    func totalUserExpences() -> Double {
        var total = 0.0
        GroupsViewModel.shared.groups.forEach { group in
            total += group.totalExpenses
        }
        return total
    }
    
    
    @MainActor
    func fetchDisplayName(userId: String) async throws -> String? {
        guard let userData = try? await self.userRepository.fetchUser(userId: userId) else { return nil }
        return userData.email
    }
    
    @MainActor
    func removeInvite(invite: Invite) async {
        guard let userId = user?.id else { return }
        let db = Firestore.firestore()
        // Remove from Firestore
        do {
            try await db.collection("Users")
                .document(userId)
                .collection("invites")
                .document(invite.id)
                .delete()
            // Remove from local user
            await MainActor.run {
                self.user.pendingInvites.removeAll { $0.id == invite.id }
            }
        } catch {
            print("Failed to remove invite: \(error)")
        }
    }
    
    @MainActor
    func addGroupToUser(userId: String?,groupId: String) async {
        // Local update
        
        if userId == nil {
            if !self.user.groupIds.contains(groupId) {
                self.user.groupIds.append(groupId)
                self.user = user
            }
        }
        // Remote update
        do {
            if (userId != nil) {
                try await self.userRepository.addGroupIdToUser(userId: userId!, groupId: groupId)
            }else{
                try await self.userRepository.addGroupIdToUser(userId: self.user.id, groupId: groupId)
            }
        } catch {
            print("Failed to update remote user groups: \(error)")
        }
    }
    
    @MainActor
    func acceptingGroupInvite(invite:Invite) async {
        await self.removeInvite(invite: invite)
        await self.addGroupToUser(userId: nil, groupId: invite.groupId)
    }
    @MainActor
    func decliningGroupInvite(invite:Invite) async {
        await self.removeInvite(invite: invite)
    }
    
    func setMonthlyBudget(budget:Int){
        Task{
            try? await self.userRepository.setMonthlyBudget(budget: budget)
        }
        self.user.monthlyBudget = budget
    }
}
