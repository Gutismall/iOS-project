//
//  ActivityCell.swift
//  iOS project
//
//  Created by Ari Guterman on 11/08/2025.
//

import UIKit

class ActivityCell: UITableViewCell {
    static let id = "ActivityCell"

    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var ActivityLabel: UILabel!
    @IBOutlet weak var NameInitials: UILabel!
    @IBOutlet weak var ConteinerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        ConteinerView.layer.cornerRadius = 8
        ConteinerView.layer.masksToBounds = false
        ConteinerView.layer.shadowColor = UIColor.black.cgColor
        ConteinerView.layer.shadowOpacity = 0.2
        ConteinerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func config(activity: Activity) {
        ActivityLabel?.text = "\(activity.prefomedBy) \(activity.type.rawValue)"
        let date = activity.timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        TimeLabel.text = formatter.string(from: date)
        NameInitials.text = getInitials(from: activity.prefomedBy)
    }

    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
    
}
