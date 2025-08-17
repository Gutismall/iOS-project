import UIKit

class MainLastActivityTableViewCell: UITableViewCell {
    static let id = "LastActivityCell"

    let containerView = UIView()
    let activityLabel = UILabel()
    let nameContainer = UIView()
    let nameInitials = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        nameContainer.backgroundColor = .systemBackground
        nameContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameContainer)

        nameInitials.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        nameInitials.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(nameInitials)

        activityLabel.font = UIFont.systemFont(ofSize: 17)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            nameContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            nameContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            nameContainer.widthAnchor.constraint(equalToConstant: 44),
            nameContainer.heightAnchor.constraint(equalToConstant: 44),

            nameInitials.centerXAnchor.constraint(equalTo: nameContainer.centerXAnchor),
            nameInitials.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),

            activityLabel.leadingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: 10),
            activityLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: -10)
        ])
    }

    func configure(activityText: String, initials: String) {
        activityLabel.text = activityText
        nameInitials.text = initials
    }
}
