// iOS project/ViewController/AppLoaderViewController.swift
import UIKit
import FirebaseAuth

class AppLoaderViewController: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupIndicator()
        loadData()
    }

    private func setupIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    private func loadData() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        Task { @MainActor in
            // Load user data
            
            UserViewModel.resetShared()
            GroupsViewModel.resetShared()
            ActivityViewModel.resetShared()
            
            await UserViewModel.shared.fetchUser(userId: uid)
            // Load group data
            let groupIds = UserViewModel.shared.user?.groupIds ?? []
            await GroupsViewModel.shared.fetchGroups(groupIds: groupIds)
            
            var allActivities = GroupsViewModel.shared.groups.flatMap { $0.activities }
            allActivities.sort {$0.timestamp.seconds < $1.timestamp.seconds }
            ActivityViewModel.shared.setActivities(activities: allActivities)
            
            showMainScreen()
        }
    }

    private func showMainScreen() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        let mainVC = UIStoryboard(name: "MainScreen", bundle: nil).instantiateInitialViewController()!
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = mainVC
        }
    }
}
