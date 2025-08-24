import UIKit
import SwiftUI
import Lottie
import FirebaseAuth
import Combine
import Kingfisher

class MainViewController: UIViewController {
    
    @IBOutlet weak var monthTitleLabel: UILabel!
//    @IBOutlet weak var budgetTitleLabel: UILabel!
    @IBOutlet weak var lastActivity: UITableView!
    @IBOutlet weak var noGroupsLabel: UILabel!
    @IBOutlet weak var groupsSpending: UITableView!
    @IBOutlet weak var topCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
//    @IBOutlet weak var budgetProgressBar: UIProgressView!
    @IBOutlet weak var topCardHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomCardHeight: NSLayoutConstraint!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var swiftUIView: UIView!
    
    private var swiftUIHostingController: UIHostingController<SwiftUIView>?
    private let progressModel = ProgressModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAnimation()
        embedSwiftUI()
        lastActivity.register(MainLastActivityTableViewCell.self, forCellReuseIdentifier: MainLastActivityTableViewCell.id)
        
        GroupsViewModel.shared.$groups.receive(on: DispatchQueue.main).sink { [weak self] _ in
            let isEmpty = GroupsViewModel.shared.groups.isEmpty
            if isEmpty{
                self?.groupsSpending.isHidden = true
                self?.noGroupsLabel.isHidden = false
            }
            else{
                self?.groupsSpending.isHidden = false
                self?.noGroupsLabel.isHidden = true
                
            }
            self?.groupsSpending.reloadData()
            self?.progressModel.updateBudget()
        }.store(in: &cancellables)
        
        ActivityViewModel.shared.$activities.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.lastActivity.reloadData()
        }.store(in: &cancellables)
        
        UserViewModel.shared.$user.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.progressModel.updateBudget()
            self?.groupsSpending.reloadData()
            self?.lastActivity.reloadData()
        }.store(in: &cancellables)
        
        // Stop reacting to model changes when logout starts
        NotificationCenter.default.publisher(for: .willLogout)
            .sink { [weak self] _ in
                // Cancel all Combine sinks so table reloads / UI updates won't fire
                self?.cancellables.removeAll()
            }
            .store(in: &cancellables)
        
        initTableViews()
        initViews()
    }
    
    func initViews() {
        updateTopCardStyle()
        updateBottomCardStyle()
        updateMonthTitleLabel()
    }
    
    func initTableViews() {
        groupsSpending.delegate = self
        groupsSpending.dataSource = self
        
        lastActivity.delegate = self
        lastActivity.dataSource = self
        
        groupsSpending.estimatedRowHeight = 70
        groupsSpending.rowHeight = UITableView.automaticDimension
        
        let uin = UINib(nibName: "ActivityCell", bundle: nil)
        lastActivity.register(uin, forCellReuseIdentifier: ActivityCell.id)
    }
    
    func updateMonthTitleLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: Date())
        monthTitleLabel.text = "\(monthName) BREAKDOWN"
    }

    
    func updateTopCardStyle() {
        groupsSpending.layer.cornerRadius = 20
        groupsSpending.layer.masksToBounds = true
        
        
        topCard.layer.shadowOpacity = 0.6
        topCard.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        topCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        topCard.layer.shadowRadius = 10
        topCard.layer.cornerRadius = 20
        
        
    }
    
    func updateBottomCardStyle() {
        lastActivity.layer.cornerRadius = 20
        lastActivity.layer.masksToBounds = true
        
        bottomCard.layer.shadowOpacity = 0.6
        bottomCard.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        bottomCard.layer.shadowOffset = CGSize(width: 0, height: 3)
        bottomCard.layer.shadowRadius = 10
        bottomCard.layer.cornerRadius = 20
        
        
    }
    
    private func initAnimation() {
        let lottieView = LottieAnimationView(name: "Money rain")
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.contentMode = .scaleAspectFill
        lottieView.loopMode = .loop
        lottieView.play()
        animationView.addSubview(lottieView)
        NSLayoutConstraint.activate([
            lottieView.leadingAnchor.constraint(equalTo: animationView.leadingAnchor),
            lottieView.trailingAnchor.constraint(equalTo: animationView.trailingAnchor),
            lottieView.topAnchor.constraint(equalTo: animationView.topAnchor),
            lottieView.bottomAnchor.constraint(equalTo: animationView.bottomAnchor)
        ])
    }
    
    private func embedSwiftUI() {
        // Remove previous hosting controller if exists
        swiftUIHostingController?.willMove(toParent: nil)
        swiftUIHostingController?.view.removeFromSuperview()
        swiftUIHostingController?.removeFromParent()

        // Create SwiftUIView with the desired progress
        let progressView = SwiftUIView(model: progressModel)

        // Create hosting controller
        let hostingController = UIHostingController(rootView: progressView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        // Add as child
        addChild(hostingController)
        swiftUIView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: swiftUIView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: swiftUIView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: swiftUIView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: swiftUIView.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)

        swiftUIHostingController = hostingController
    }
    
    private func updateTablesSizes(){
        self.lastActivity.reloadData()
        self.lastActivity.layoutIfNeeded()
        self.bottomCardHeight.constant = self.lastActivity.contentSize.height
        
        self.groupsSpending.reloadData()
        self.groupsSpending.layoutIfNeeded()
        self.topCardHeight.constant = self.groupsSpending.contentSize.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTablesSizes()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(GroupsViewModel.shared.groups.count)
    }
    
    deinit {
        // Extra safety: ensure any remaining subscriptions are cancelled
        cancellables.removeAll()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.lastActivity {
            return min(ActivityViewModel.shared.activities.count, 10)
        } else {
            return min(GroupsViewModel.shared.groups.count, 10)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.lastActivity {
            guard let cell = lastActivity.dequeueReusableCell(withIdentifier: ActivityCell.id, for: indexPath) as? ActivityCell else {
                return UITableViewCell()
            }
            cell.config(activity: ActivityViewModel.shared.activities[indexPath.row])
            return cell
        } else {
            guard let cell = groupsSpending.dequeueReusableCell(withIdentifier: MainGroupsTableViewCell.id, for: indexPath) as? MainGroupsTableViewCell else {
                return UITableViewCell()
            }
            let group = GroupsViewModel.shared.groups[indexPath.row]
            cell.config(group: group)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.groupsSpending {
            guard let tabBarController = self.tabBarController,
                  let groupsNavController = tabBarController.viewControllers?[1] as? UINavigationController else { return }
            
            tabBarController.selectedIndex = 1 // Switch to Groups tab
            
            let storyboard = UIStoryboard(name: "MainScreen", bundle: nil)
            guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "GroupDeteails") as? GroupDeteails else { return }
            detailsVC.group = GroupsViewModel.shared.groups[indexPath.row]
            
            groupsNavController.pushViewController(detailsVC, animated: true)
        }
    }
}

extension Notification.Name {
    static let willLogout = Notification.Name("willLogout")
}
