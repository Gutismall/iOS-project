//
//  MainGroupsTableViewCell.swift
//  iOS project
//
//  Created by Ari Guterman on 07/08/2025.
//

import UIKit

class MainGroupsTableViewCell: UITableViewCell {
    static let id = "HomeGroupCell"
    
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var spendingContainer: UIView!
    @IBOutlet weak var groupIcon: UIImageView!
    @IBOutlet weak var spendingAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ContainerView.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        ContainerView.layer.shadowOpacity = 0.2
        ContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ContainerView.layer.shadowRadius = 4
        
        spendingContainer.layer.cornerRadius = 15
        spendingContainer.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
        spendingContainer.layer.shadowOpacity = 0.1
        spendingContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        spendingContainer.layer.shadowRadius = 4
        
        groupIcon.layer.cornerRadius = groupIcon.frame.height / 2
        groupIcon.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(group:Group){
        groupName.text = group.name
        groupIcon.image = UIImage(systemName: group.groupIcon)
        spendingAmount.text = group.totalExpenses.description
        
    }

}
