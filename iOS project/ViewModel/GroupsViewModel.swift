import Foundation
import FirebaseAuth
import FirebaseFirestore


extension Notification.Name {
    static let groupsDidUpdate = Notification.Name("groupsDidUpdate")
    static let chargesDidUpdate = Notification.Name("chargesDidUpdate")
}

final class GroupsViewModel: ObservableObject {
    static var shared = GroupsViewModel()
    var groupRepository = GroupsRepository()

    @Published private(set) var groups: [Group] = []

    private init() {}

    static func resetShared() {
        shared = GroupsViewModel()
    }

    func resetState() {
        groups.removeAll()
    }
    @MainActor
    func fetchGroups(groupIds: [String]) async {
        if groupIds.isEmpty { return }
        else{
            self.groups = try! await self.groupRepository.fetchGroups(groupIds: groupIds)
        }
    }

    // MARK: - Mutations

    /// Create a group, add current user to it, optionally invite emails.
    func createGroup(groupName: String, icon: String, invitedEmails: [String]) async throws {
        //create new group in db
        let newGroup = try await self.groupRepository.createGroup(name: groupName, icon: icon)
        //create new activity
        let activity = ActivityViewModel.shared.buildActivity(type:.groupCreated)
        //add activity to to group localy and remote
        await self.addActivityToGroup(activity: activity, groupId: newGroup.id)
        //add the group to the user localy and remote
        await UserViewModel.shared.addGroupToUser(userId: nil ,groupId: newGroup.id)
        // Invite others (best-effort per email)
        for email in invitedEmails {
            try? await UserViewModel.shared.sendInvite(toEmail: email, groupId: newGroup.id)
        }
        
    }
    
    func addNewCharge(charge: Charge, groupId: String) async {
        do {
            if let index = self.groups.firstIndex(where: { $0.id == groupId }) {
                var updated = self.groups
                updated[index].charges.append(charge)
                self.groups = updated
                print("added new charge")
            }
            try await self.groupRepository.addChargeToGroup(charge: charge, groupId: groupId)
            let activity = ActivityViewModel.shared.buildActivity(chargeId: charge.id, type: .addCharge)
            await self.addActivityToGroup(activity: activity, groupId: groupId)
        } catch {
            print("Failed to add charge: \(error)")
        }
    }

    func addActivityToGroup(activity: Activity, groupId: String) async {
        do {
            try await self.groupRepository.addActivityToGroup(groupId: groupId, activity: activity)
            var allActivities = ActivityViewModel.shared.activities
            allActivities.insert(activity, at: 0)
            ActivityViewModel.shared.setActivities(activities: allActivities)
        } catch {
            print("Failed to add activity: \(error)")
        }
    }
    
    func reset(){
        self.groups = []
    }
    
    func deleteCharge(charge:Charge,groupId:String) async{
        do{
            if let index = self.groups.firstIndex(where: { $0.id == groupId }) {
                self.groups[index].charges.removeAll(where: { $0.id == charge.id })
            }
            try await self.groupRepository.removeChargeFromGroup(charge: charge, groupId: groupId)
            let activity = ActivityViewModel.shared.buildActivity(chargeId: charge.id, type: .removeCharge)
            await self.addActivityToGroup(activity: activity, groupId: groupId)
        }catch{
            print("Failed to remove charge: \(error)")
        }
        
    }
    
    func addGroup(groupId: String) async {
        do {
            // Fetch the group details from repository
            let fetchedGroup = try await self.groupRepository.fetchGroups(groupIds: [groupId]).first
            ActivityViewModel.shared.fetchActivities(for: [groupId])
            if let group = fetchedGroup {
                await MainActor.run {
                    self.groups.append(group)
                }
            }
            // Update remote members with current user
            try await self.groupRepository.addCurrentUserToGroup(groupId: groupId)
        } catch {
            print("Failed to add new group: \(error)")
        }
    }
}
