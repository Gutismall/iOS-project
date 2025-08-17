//
//  SettingsCell.swift
//  iOS project
//
//  Created by Ari Guterman on 10/08/2025.
//

import UIKit

class SettingsCell: UITableViewCell {
    static let id = "SettingsCell"

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
