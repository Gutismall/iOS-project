//
//  GroupInfoCollectionViewCell.swift
//  iOS project
//
//  Created by Ari Guterman on 07/08/2025.
//

import UIKit

class GroupInfoCollectionViewCell: UICollectionViewCell {
    
    static var id = "infoCell"
    
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardTitle: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            layer.cornerRadius = 12
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.15
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 6
            layer.masksToBounds = false
            backgroundColor = .white
        }
}
