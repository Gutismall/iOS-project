import FirebaseAuth
import UIKit

class SettingsVM{
    
    func signOut() throws{
        NotificationCenter.default.post(name: .willLogout, object: nil)

        // now it's safe to mutate models without triggering UI sinks
        UserViewModel.shared.resetState()
        GroupsViewModel.shared.resetState()
        ActivityViewModel.shared.resetState()

        try Auth.auth().signOut()

        // swap root as you already do...
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialVC = storyboard.instantiateInitialViewController() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = initialVC
                window.makeKeyAndVisible()
            }
        }
    }
}
