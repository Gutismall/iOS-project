//
//  GroupDetailsInfoUserListTableViewCell.swift
//  iOS project
//
//  Created by Ari Guterman on 06/08/2025.
//

import UIKit

class GroupDetailsInfoUserListTableViewCell: UITableViewCell {
    
    static let id = "UserInfoCell"

    @IBOutlet weak var IconContainer: UIView!
    @IBOutlet weak var UserIcon: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var isAdmin: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        IconContainer.layer.cornerRadius = 8
        IconContainer.layer.masksToBounds = false
        IconContainer.layer.shadowColor = UIColor.black.cgColor
        IconContainer.layer.shadowOpacity = 0.2
        IconContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
    }
    
    func config(userName:String,userIcon:String,isAdmin:Bool){
        self.UserName.text = userName
        self.isAdmin.text = isAdmin ? "Admin" : ""

        if let url = URL(string: userIcon), url.scheme == "http" || url.scheme == "https" {
            self.UserIcon.kf.setImage(with: url)
        } else {
            self.UserIcon.image = UIImage(systemName: userIcon)
        }
    }
}
