//
//  GroupsViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 21/06/2025.
//

import UIKit
import Kingfisher
import Combine

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var GroupsTableView: UITableView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GroupsTableView.delegate = self
        GroupsTableView.dataSource = self
        GroupsTableView.estimatedRowHeight = 100
        GroupsTableView.rowHeight = UITableView.automaticDimension
        
        GroupsViewModel.shared.$groups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.GroupsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowGroupDetails",
              let detailsVC = segue.destination as? GroupDeteails else { return }

        var indexPath: IndexPath?
        if let ip = sender as? IndexPath {
            indexPath = ip
        } else if let cell = sender as? UITableViewCell {
            indexPath = GroupsTableView.indexPath(for: cell)
        }

        if let indexPath = indexPath {
            let group = GroupsViewModel.shared.groups[indexPath.row]
            detailsVC.group = group
        }
    }
}

extension GroupsViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupsViewModel.shared.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = GroupsTableView.dequeueReusableCell(withIdentifier: GroupsTableViewCell.id, for: indexPath) as? GroupsTableViewCell else {
            return UITableViewCell()
        }
        let group = GroupsViewModel.shared.groups[indexPath.row]
        cell.config(group: group)
        return cell
    }
    
}

class GroupDeteails : UIViewController{
    var group : Group!
    
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var chargesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryContainerView.isHidden = true
        chargesContainerView.isHidden = false
    }
    @IBAction func OnTapSegment(_ sender: UISegmentedControl) {
        
        summaryContainerView.isHidden = true
        chargesContainerView.isHidden = true

        switch sender.selectedSegmentIndex {
        case 0:
            chargesContainerView.isHidden = false
        case 1:
            summaryContainerView.isHidden = false
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let summaryVC = segue.destination as? GroupDeteailsInfo {
            summaryVC.group = self.group
        } else if let chargesVC = segue.destination as? GroupDeteailsCharges {
            chargesVC.group = self.group
        }
    }
    
}

class GroupDeteailsInfo: UIViewController{
    var group: Group!
    
    @IBOutlet weak var mostUsedCategory: UILabel!
    @IBOutlet weak var totalChargesNumber: UILabel!
    @IBOutlet weak var totalExpencesNumber: UILabel!
    @IBOutlet weak var groupNameTitle: UILabel!
    @IBOutlet weak var membersTable: UITableView!
    private var groupInfoViewModel: GroupInfoViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersTable.delegate = self
        membersTable.dataSource = self
        
        membersTable.estimatedRowHeight = 85
        membersTable.rowHeight = UITableView.automaticDimension
        
        GroupsViewModel.shared.$groups.receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self else {
                return
            }
            if let updatedGroup = GroupsViewModel.shared.groups.first(where: { $0.id == self.group.id }) {
                    self.group = updatedGroup
            }
            self.membersTable.reloadData()
            self.updateInfo()
        }.store(in: &cancellables)
    }
    
    func updateInfo() {
        groupInfoViewModel = GroupInfoViewModel(group: group)
        mostUsedCategory.text = groupInfoViewModel.statistics[0].description
        totalChargesNumber.text = groupInfoViewModel.statistics[1].description
        totalExpencesNumber.text = groupInfoViewModel.statistics[3].description
    }
}

extension GroupDeteailsInfo : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = membersTable.dequeueReusableCell(withIdentifier: GroupDetailsInfoUserListTableViewCell.id, for: indexPath) as? GroupDetailsInfoUserListTableViewCell else {
            return UITableViewCell()
        }
        var isAdmin = false
        if indexPath.row == 0 {
            isAdmin = true
        }
        cell.config(userId: group.members[indexPath.row],isAdmin: isAdmin)
        return cell
    }
}

class GroupDeteailsCharges: UIViewController,ChargeModalDelegate{
    
    var group: Group!
    @IBOutlet weak var noChargesLabel: UILabel!
    @IBOutlet weak var ChargesTableVIew: UITableView!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ChargesTableVIew.delegate = self
        ChargesTableVIew.dataSource = self
        
        ChargesTableVIew.estimatedRowHeight = 80
        ChargesTableVIew.rowHeight = UITableView.automaticDimension
        
        GroupsViewModel.shared.$groups.receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self else {
                return
            }
            if let updatedGroup = GroupsViewModel.shared.groups.first(where: { $0.id == self.group.id }) {
                    self.group = updatedGroup
                }
            
            let isEmpty = group.charges.isEmpty
            self.noChargesLabel.isHidden = !isEmpty
            self.ChargesTableVIew.isHidden = isEmpty
            
            print("executed")
            self.ChargesTableVIew.reloadData()
        }.store(in: &cancellables)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "New Charge Surge",
           let modalVC = segue.destination as? ChargeModalViewController {
            modalVC.delegate = self
        }
    }
    
    func didCreateCharge(_ charge: Charge) {
        Task {
            await GroupsViewModel.shared.addNewCharge(charge: charge, groupId: group.id)
            NotificationCenter.default.post(name: .chargesDidUpdate, object: nil)
        }
    }
    
    
    
}

extension GroupDeteailsCharges : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.charges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ChargesTableVIew.dequeueReusableCell(withIdentifier: GroupDetailsChargesTableViewCell.id, for: indexPath) as? GroupDetailsChargesTableViewCell else {
            return UITableViewCell()
        }
        let charge = group.charges[indexPath.row]
        cell.config(charge: charge)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            let charge = self.group.charges[indexPath.row]
            
            Task {
                // Expect this to return Bool for success; adjust if your API differs
                await GroupsViewModel.shared.deleteCharge(charge: charge, groupId: self.group.id)
                
                await MainActor.run {
                    NotificationCenter.default.post(name: .chargesDidUpdate, object: nil)
                    completion(true)
                }
            }
        }
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
}
