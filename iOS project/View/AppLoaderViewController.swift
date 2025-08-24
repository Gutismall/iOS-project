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
            
            let user = await UserViewModel.shared.fetchUser(userId: uid)
            UserViewModel.shared.setUser(user: user)
            
            print(user)
            // Load group data
            let groupIds = user.groupIds
            await GroupsViewModel.shared.fetchGroups(groupIds: groupIds)
            
            ActivityViewModel.shared.fetchActivities(for: groupIds)
            
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
