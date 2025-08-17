//
//  RounderTableView.swift
//  iOS project
//
//  Created by Ari Guterman on 16/08/2025.
//

import UIKit

class RounderTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
            super.init(frame: frame, style: style)
            setupCorners()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupCorners()
        }

        private func setupCorners() {
            self.layer.cornerRadius = 20
            self.layer.masksToBounds = true
            self.layer.shadowOpacity = 0.6
            self.layer.shadowColor = UIColor(named: "Secondery Color")?.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.layer.shadowRadius = 10
        }

}
