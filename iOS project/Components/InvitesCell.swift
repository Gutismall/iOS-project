//
//  InvitesCell.swift
//  iOS project
//
//  Created by Ari Guterman on 08/08/2025.
//

import UIKit

protocol InvitesCellDelegate: AnyObject {
    func didTapAccept(on cell: InvitesCell)
    func didTapDecline(on cell: InvitesCell)
}

class InvitesCell: UITableViewCell {
    static let id = "invitesCell"
    weak var delegate: InvitesCellDelegate?

    @IBOutlet weak var inviteLabel: UILabel!
    @IBOutlet weak var DeclineButton: UIButton!
    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var cotainerView: UIView!

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        delegate?.didTapAccept(on: self)
    }

    @IBAction func declineButtonTapped(_ sender: UIButton) {
        delegate?.didTapDecline(on: self)
    }
    
    func config(invite:Invite) async{
        self.inviteLabel.text = try? await UserViewModel.shared.fetchDisplayName(userId: invite.inviterUid)
    }
}
