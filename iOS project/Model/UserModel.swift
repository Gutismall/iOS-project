// Model/User.swift
import Foundation
import FirebaseCore

struct User :Codable{
    let id: String
    var groupIds: [String]
    var monthlyBudget: Int
    var photoURL:String 
    let email:String
    let name: String
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
