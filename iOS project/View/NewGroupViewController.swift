//
//  NewGroupViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 08/08/2025.
//

// iOS project/View/NewGroupViewController.swift
import UIKit

class NewGroupViewController: UIViewController {
    private var selectedIcon: String!
    
    @IBOutlet weak var groupIconSelectorCollection: UICollectionView!
    @IBOutlet weak var groupNameTextInput: UITextField!
    @IBOutlet weak var groupIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupIconSelectorCollection.delegate = self
        groupIconSelectorCollection.dataSource = self
        groupIconSelectorCollection.register(IconCellCollectionViewCell.self, forCellWithReuseIdentifier: IconCellCollectionViewCell.id)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addMembersSurge" {
            guard let groupName = groupNameTextInput.text, !groupName.isEmpty else {
                showAlert("Group must have a name")
                return false
            }
            guard selectedIcon != nil else {
                showAlert("Select Group Icon")
                return false
            }
        }
        return true // Allow segue if all validations pass
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMembersSurge" {
            if let destinationVC = segue.destination as? AddMembersViewController {
                destinationVC.groupName = groupNameTextInput.text
                destinationVC.iconSelected = selectedIcon
            }
        }
    }
    private func showAlert(_ message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
extension NewGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionViewStyle(){
        groupIconSelectorCollection.clipsToBounds = false
        groupIconSelectorCollection.superview?.clipsToBounds = false
        groupIconSelectorCollection.backgroundColor = UIColor.systemGray6
        groupIconSelectorCollection.layer.cornerRadius = 8
        groupIconSelectorCollection.layer.borderWidth = 1 / UIScreen.main.scale
        groupIconSelectorCollection.layer.borderColor = UIColor.gray.cgColor
        groupIconSelectorCollection.layer.shadowColor = UIColor.black.cgColor
        groupIconSelectorCollection.layer.shadowOpacity = 0.25
        groupIconSelectorCollection.layer.shadowOffset = CGSize(width: 0, height: 2)
        groupIconSelectorCollection.layer.shadowRadius = 4
        groupIconSelectorCollection.layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IconCellCollectionViewCell.icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCellCollectionViewCell.id, for: indexPath) as! IconCellCollectionViewCell
        cell.iconImageView.image = UIImage(systemName:IconCellCollectionViewCell.icons[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        groupIcon.image = UIImage(systemName:IconCellCollectionViewCell.icons[indexPath.item])
        selectedIcon = IconCellCollectionViewCell.icons[indexPath.item]
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // Adjust values as needed
    }
    
}


class AddMembersViewController:UIViewController{
    private var invitedMailList : [String] = []
    
    fileprivate var groupName: String?
    fileprivate var iconSelected: String!
    
    @IBOutlet weak var invitedMembersTable: UITableView!
    @IBOutlet weak var newMemberEmailTextInput: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: groupName))")
        
        invitedMembersTable.delegate = self
        invitedMembersTable.dataSource = self
        
    }
    @IBAction func onTapAdd(_ sender: Any) {
        guard let email = newMemberEmailTextInput.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert("Please enter an email.")
            return
        }
        invitedMailList.append(email)
        invitedMembersTable.reloadData()
    }
    
    
    private func showAlert(_ message: String) {
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func onTapDone(_ sender: Any) {
        if invitedMailList.isEmpty {
            showAlert("Please add people to invted list")
            return
        }
        else{
            Task {
                do {
                    try await GroupsViewModel.shared.createGroup(groupName: groupName!, icon: iconSelected, invitedEmails: invitedMailList)
                    
                    let ac = UIAlertController(title: nil, message: "Group created successfully!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    present(ac, animated: true)
                } catch {
                    showAlert("Failed to create group: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension AddMembersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedMailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitedMemberCell", for: indexPath)
        cell.textLabel?.text = invitedMailList[indexPath.row]
        return cell
    }
    
    
}
