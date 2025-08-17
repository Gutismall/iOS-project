//
//  GroupDetailsChargesTableViewCell.swift
//  iOS project
//
//  Created by Ari Guterman on 06/08/2025.
//

import UIKit

class GroupDetailsChargesTableViewCell: UITableViewCell {
    
    static let id = "ChargesCell"

    @IBOutlet weak var ImageContiner: UIView!
    @IBOutlet weak var CategotyIcon: UIImageView!
    @IBOutlet weak var chargeDescription: UILabel!
    @IBOutlet weak var CreatedBy: UILabel!
    @IBOutlet weak var AmountContiner: UIView!
    @IBOutlet weak var AmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImageContiner.layer.cornerRadius = CategotyIcon.frame.height / 2
        ImageContiner.layer.shadowColor = UIColor.black.cgColor
        ImageContiner.layer.shadowOpacity = 0.2
        ImageContiner.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        AmountContiner.layer.cornerRadius = 8
        AmountContiner.layer.shadowColor = UIColor.black.cgColor
        AmountContiner.layer.shadowOpacity = 0.2
        AmountContiner.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(charge:Charge){
        self.CategotyIcon.image = charge.category.icon
        self.AmountLabel.text = "\(charge.amount) $"
        self.CreatedBy.text = "\(charge.createdByName)"
        self.chargeDescription.text = charge.description
    }

}
