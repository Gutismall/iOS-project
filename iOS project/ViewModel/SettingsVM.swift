import FirebaseAuth
import UIKit

class SettingsVM{
    
    func signOut() throws{
        UserViewModel.shared.resetState()
        GroupsViewModel.shared.resetState()
        ActivityViewModel.shared.resetState()
        
        try Auth.auth().signOut()
        
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
