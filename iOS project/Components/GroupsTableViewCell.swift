//
//  GroupsTableViewCell.swift
//  iOS project
//
//  Created by Ari Guterman on 02/08/2025.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    
    static let id = "GroupCell"
    
    @IBOutlet weak var IconContiner: UIView!
    @IBOutlet weak var GroupIcon: UIImageView!
    @IBOutlet weak var GroupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        IconContiner.layer.cornerRadius = IconContiner.frame.height / 2
        IconContiner.layer.shadowColor = UIColor.black.cgColor
        IconContiner.layer.shadowOpacity = 0.2
        IconContiner.layer.shadowOffset = CGSize(width: 0, height: 2)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func config(group:Group){
        self.GroupIcon.image = UIImage(systemName: group.groupIcon)
        self.GroupLabel.text = group.name
    }

}
