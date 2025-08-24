//
//  SettingsViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 21/06/2025.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var HightConstraint: NSLayoutConstraint!
    @IBOutlet weak var SettingsTable: UITableView!
    @IBOutlet weak var TopContainer: UIView!
    @IBOutlet weak var userIconDisplay: UIImageView!
    @IBOutlet weak var userEmailText: UILabel!
    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var IconImageViewContainer: UIView!
    
    let ViewModel = SettingsVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TopContainer.layer.cornerRadius = 10
        tableConfig()
        userConfig()
        self.userIconDisplay.layer.cornerRadius = self.userIconDisplay.frame.width / 2
        self.IconImageViewContainer.layer.cornerRadius = self.IconImageViewContainer.frame.width / 2
        self.IconImageViewContainer.layer.shadowColor = UIColor.black.cgColor
        self.IconImageViewContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.IconImageViewContainer.layer.shadowOpacity = 0.5
        self.IconImageViewContainer.layer.shadowRadius = 12 
    }
    private func userConfig(){
        self.userNameText.text = UserViewModel.shared.user.name
        
        self.userEmailText.text = UserViewModel.shared.user.email
        
        let photoURL = UserViewModel.shared.user.photoURL
        
        print(photoURL)
        
        if let url = URL(string: photoURL), url.scheme == "http" || url.scheme == "https" {
            self.userIconDisplay.kf.setImage(with: url)
        } else {
            self.userIconDisplay.image = UIImage(systemName: photoURL)
        }
    }
    
    
    private func tableConfig(){
        SettingsTable.dataSource = self
        SettingsTable.delegate = self
        
        SettingsTable.layer.cornerRadius = 8
        SettingsTable.clipsToBounds = true
        
        SettingsTable.rowHeight = UITableView.automaticDimension
        
        SettingsTable.layer.cornerRadius = 20
        SettingsTable.layer.masksToBounds = true
        
        SettingsTable.tableHeaderView = nil
        
        tableContainer.layer.shadowOpacity = 0.6
        tableContainer.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        tableContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        tableContainer.layer.shadowRadius = 10
        tableContainer.layer.cornerRadius = 20
        

//        SettingsTable.tableHeaderView = UIView()
//        SettingsTable.tableFooterView = UIView()
//        SettingsTable.separatorInset = .zero
//        SettingsTable.layoutMargins = .zero
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SettingsTable.reloadData()
        SettingsTable.layoutIfNeeded()
        self.HightConstraint.constant = self.SettingsTable.contentSize.height
        
    }
}

extension SettingsViewController:UITableViewDelegate,UITableViewDataSource{
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
            let changebudgetVC = ChnageBudgetViewController()
            present(changebudgetVC,animated: true)
            break
        case 1:
            self.performSegue(withIdentifier: "ShowChangeIconSegue", sender: UITableViewCell.self)
            return
        case 2:
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

