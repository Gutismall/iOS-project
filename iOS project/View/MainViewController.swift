import UIKit
import FirebaseAuth
import Combine
import Kingfisher

class MainViewController: UIViewController {
    
    @IBOutlet weak var monthTitleLabel: UILabel!
    @IBOutlet weak var budgetTitleLabel: UILabel!
    @IBOutlet weak var lastActivity: UITableView!
    @IBOutlet weak var groupsSpending: UITableView!
    @IBOutlet weak var topCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
    @IBOutlet weak var budgetProgressBar: UIProgressView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastActivity.register(MainLastActivityTableViewCell.self, forCellReuseIdentifier: MainLastActivityTableViewCell.id)
        initTableViews()
        initViews()
        
        GroupsViewModel.shared.$groups.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.groupsSpending.reloadData()
            self?.updateBudgetProgressBar()
        }.store(in: &cancellables)
        
        ActivityViewModel.shared.$activities.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.lastActivity.reloadData()
        }.store(in: &cancellables)
    }
    
    func initViews() {
        updateTopCardStyle()
        updateBottomCardStyle()
        updateMonthTitleLabel()
        updateBudgetTitleLabel()
        updateBudgetProgressBar()
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
        
        updateGroupsTableBackground()
    }
    
    func updateGroupsTableBackground() {
        let groups = GroupsViewModel.shared.groups
        if groups.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = "No groups to display"
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            messageLabel.textColor = .lightGray
            groupsSpending.backgroundView = messageLabel
        } else {
            groupsSpending.backgroundView = nil
        }
    }
    
    func updateMonthTitleLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: Date())
        monthTitleLabel.text = "\(monthName) BREAKDOWN"
    }
    
    func updateBudgetTitleLabel() {
        let today = Date.now
        let calendar = Calendar.current
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        budgetTitleLabel.text = "\(formatter.string(from: firstDay)) - \(formatter.string(from: today))"
    }
    
    func updateBudgetProgressBar() {
        budgetProgressBar.transform = CGAffineTransform(scaleX: 1, y: 4)
        budgetProgressBar.progress = Float(UserViewModel.shared.totalUserExpences() / UserViewModel.shared.user.monthlyBudget)
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
