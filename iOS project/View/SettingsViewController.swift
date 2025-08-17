//
//  SettingsViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 21/06/2025.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var HightConstraint: NSLayoutConstraint!
    @IBOutlet weak var SettingsTable: UITableView!
    @IBOutlet weak var TopContainer: UIView!
    @IBOutlet weak var userIconDisplay: UIImageView!
    @IBOutlet weak var userEmailText: UILabel!
    @IBOutlet weak var userNameText: UILabel!
    private var contentSizeObservation: NSKeyValueObservation?
    
    let ViewModel = SettingsVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TopContainer.layer.cornerRadius = 10
        config()
        let displayName = Auth.auth().currentUser?.displayName
        self.userNameText.text = displayName
        
        self.userEmailText.text = UserViewModel.shared.user.email
        
        let photoURL = UserViewModel.shared.user.photoURL
        print(photoURL)
        if let url = URL(string: photoURL), url.scheme == "http" || url.scheme == "https" {
            self.userIconDisplay.kf.setImage(with: url)
        } else {
            self.userIconDisplay.image = UIImage(systemName: photoURL)
        }
        
    }
    deinit {
        contentSizeObservation?.invalidate()
    }
    
}

extension SettingsViewController:UITableViewDelegate,UITableViewDataSource{
    func config(){
        SettingsTable.dataSource = self
        SettingsTable.delegate = self
        
        SettingsTable.isScrollEnabled = false
        SettingsTable.rowHeight = UITableView.automaticDimension
        SettingsTable.estimatedRowHeight = 56
        
        // Remove default paddings / extra separators
        if #available(iOS 15.0, *) {
            SettingsTable.sectionHeaderTopPadding = 0
        }
        SettingsTable.tableHeaderView = UIView()
        SettingsTable.tableFooterView = UIView()
        SettingsTable.separatorInset = .zero
        SettingsTable.layoutMargins = .zero
        
        // Rounded corners that actually clip
        SettingsTable.layer.cornerRadius = 8
        SettingsTable.clipsToBounds = true
        
        // Observe content size to drive the height constraint
        contentSizeObservation = SettingsTable.observe(\.contentSize, options: [.new]) { [weak self] table, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.HightConstraint.constant = table.contentSize.height
                self.view.layoutIfNeeded()
            }
        }
        
        // Initial load -> triggers the observer above
        SettingsTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = SettingsTable.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        switch indexPath.row {
            //Budget
        case 0:
            cell.iconImage.image = UIImage(named: "budgetIcon")
            cell.settingLabel.text = "Budget"
            break
            //Change Icon
        case 1:
            cell.iconImage.image = UIImage(named: "changeIconIcon")
            cell.settingLabel.text = "Change Icon"
            break
            //Reset Password
        case 2:
            cell.iconImage.image = UIImage(named: "resetPasswordIcon")
            cell.settingLabel.text = "Reset Password"
            break
            //Log out
        case 3:
            cell.iconImage.image = UIImage(named: "logoutIcon")
            cell.settingLabel.text = "Log Out"
            break
        default:
            break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            return
        case 2:
            return
        case 3:
            do{
                try ViewModel.signOut()
            }catch{
                
            }
            
            return
        default:
            return
        }
    }
}

