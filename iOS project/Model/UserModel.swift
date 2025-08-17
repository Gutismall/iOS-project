// Model/User.swift
import Foundation
import FirebaseCore

struct User :Codable{
    var id: String
    var groupIds: [String]
    var monthlyBudget: Double
    var photoURL:String
    var email:String
    var isFirstTime: Bool
    var pendingInvites: [Invite]
}

struct Invite :Codable{
    let id: String
    let groupId: String
    let inviterUid: String
    let status: InviteStatus
    let createdAt: Timestamp
}

enum InviteStatus: String, Codable {
    case pending
    case accepted
    case declined
}
