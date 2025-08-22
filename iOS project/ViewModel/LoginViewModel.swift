import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit

final class LoginViewModel {
    private let db = Firestore.firestore()

    func login(email: String, password: String) async -> (success: Bool, isFirstLogin: Bool?, errorMessage: String?) {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid

            let doc = try await db.collection("Users").document(uid).getDocument()
            guard let data = doc.data() else {
                return (false, nil, "User data not found")
            }
            let isFirstTime = data["isFirstTime"] as? Bool ?? true
            return (true, isFirstTime, nil)
        } catch {
            return (false, nil, "Login failed with error: \(error.localizedDescription)")
        }
    }

    func register(fullName:String,email: String, password: String) async -> (success: Bool, errorMessage: String?) {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            let newUser = User(
                id: user.uid,
                groupIds: [],
                monthlyBudget: 0,
                photoURL: "",
                email: user.email ?? email,
                name: fullName,
                isFirstTime: true,
                pendingInvites: []
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(newUser)
            var userData = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            userData.removeValue(forKey: "id")
            userData.removeValue(forKey: "pendingInvites")

            try await db.collection("Users").document(user.uid).setData(userData)
            try Auth.auth().signOut()
            return (true, nil)
        } catch {
            return (false, error.localizedDescription)
        }
    }

    func connectWithGoogle(uiViewController: UIViewController) async -> (success: Bool, isFirstLogin: Bool?, errorMessage: String?) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing clientID")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let userAuth = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                DispatchQueue.main.async {
                    GIDSignIn.sharedInstance.signIn(withPresenting: uiViewController) { result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let result = result {
                            continuation.resume(returning: result)
                        }
                    }
                }
            }
            let user = userAuth.user
            guard let idToken = user.idToken else {
                throw NSError(domain: "Invalid user", code: 0, userInfo: nil)
            }
            let accessToken = user.accessToken
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credentials)
            let firebaseUser = result.user

            let uid = firebaseUser.uid
            var isFirstTime = true

            if result.additionalUserInfo?.isNewUser == true {
                let newUser = User(
                    id: uid,
                    groupIds: [],
                    monthlyBudget: 0,
                    photoURL: "",
                    email: firebaseUser.email ?? "",
                    name: firebaseUser.displayName ?? "",
                    isFirstTime: true,
                    pendingInvites: []
                )
                let encoder = JSONEncoder()
                let data = try encoder.encode(newUser)
                var userData = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                userData.removeValue(forKey: "id")
                userData.removeValue(forKey: "pendingInvites")
                try await db.collection("Users").document(uid).setData(userData)
            } else {
                let doc = try await db.collection("Users").document(uid).getDocument()
                isFirstTime = doc.data()?["isFirstTime"] as? Bool ?? false
            }

            return (true, isFirstTime, nil)
        } catch {
            return (false, nil, error.localizedDescription)
        }
    }
}
