import UIKit
import Combine

class ActivityViewController: UIViewController {

    @IBOutlet weak var invitesTable: UITableView!
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var noActivityLabel: UILabel!

    @IBOutlet weak var ActivityTableHeightConstraints: NSLayoutConstraint!
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityTableView.delegate = self
        activityTableView.dataSource = self
        invitesTable.delegate = self
        invitesTable.dataSource = self

        let uin = UINib(nibName: "ActivityCell", bundle: nil)
        activityTableView.register(uin, forCellReuseIdentifier: ActivityCell.id)

        activityTableView.rowHeight = UITableView.automaticDimension
        invitesTable.rowHeight = UITableView.automaticDimension

        tableViews()

        // Activities updates
        ActivityViewModel.shared.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                let isEmpty = ActivityViewModel.shared.activities.isEmpty
                self.noActivityLabel.isHidden = !isEmpty
                self.activityTableView.isHidden = isEmpty
                
                self.activityTableView.reloadData()
                self.activityTableView.layoutIfNeeded()
            }
            .store(in: &cancellables)
        
        

        // Invites updates
        UserViewModel.shared.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                
                let isEmpty = UserViewModel.shared.user.pendingInvites.isEmpty
                self.invitesTable.isHidden = isEmpty
                self.invitesTable.reloadData()

                // If you want a little animation:
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.invitesTable.reloadData()
        self.invitesTable.layoutIfNeeded()
        self.ActivityTableHeightConstraints.constant = self.activityTableView.contentSize.height
        
    }
    

    func tableViews() {
        activityTableView.layer.cornerRadius = 20
        activityTableView.layer.masksToBounds = true
        activityTableView.layer.shadowOpacity = 0.6
        activityTableView.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        activityTableView.layer.shadowOffset = CGSize(width: 0, height: 3)
        activityTableView.layer.shadowRadius = 10
    }
}

extension ActivityViewController: UITableViewDataSource, UITableViewDelegate, InvitesCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == activityTableView {
            return ActivityViewModel.shared.activities.count
        } else {
            return UserViewModel.shared.user?.pendingInvites.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == activityTableView {
            guard let cell = activityTableView.dequeueReusableCell(withIdentifier: ActivityCell.id, for: indexPath) as? ActivityCell else {
                return UITableViewCell()
            }
            let activity = ActivityViewModel.shared.activities[indexPath.row]
            cell.config(activity: activity)
            return cell
        } else {
            guard let cell = invitesTable.dequeueReusableCell(withIdentifier: InvitesCell.id, for: indexPath) as? InvitesCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            Task { await cell.config(invite: UserViewModel.shared.user.pendingInvites[indexPath.row]) }
            return cell
        }
    }

    func didTapAccept(on cell: InvitesCell) {
        guard let indexPath = invitesTable.indexPath(for: cell),
              let invite = UserViewModel.shared.user?.pendingInvites[indexPath.row] else { return }
        Task { await UserViewModel.shared.acceptingGroupInvite(invite: invite) }
    }

    func didTapDecline(on cell: InvitesCell) {
        guard let indexPath = invitesTable.indexPath(for: cell),
              let invite = UserViewModel.shared.user?.pendingInvites[indexPath.row] else { return }
        Task { await UserViewModel.shared.decliningGroupInvite(invite: invite) }
    }
}
