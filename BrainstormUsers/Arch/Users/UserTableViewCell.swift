//
//  UserTableViewCell.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import Kingfisher
import UIKit

final class UserTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet private var avatarImageView: UIImageView! { didSet { avatarImageView.cornerRadius = 5 } }
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }

    // MARK: - Injection

    var user: User! { didSet { configure() } }

    private func configure() {
        avatarImageView.kf.setImage(with: user.avatar)
        nameLabel.text = user.fullName
        infoLabel.text = user.info
        countryLabel.text = user.country
        addressLabel.text = user.address
    }

    // MARK: Search

    var search: String? { didSet { highlightSearch() } }
    private lazy var searchLabels = [nameLabel, infoLabel, countryLabel, addressLabel]

    private func highlightSearch() {
        searchLabels.forEach {
            guard let text = $0?.text else { return }
            $0?.attributedText = NSAttributedString(string: text)
        }

        let search = self.search ?? ""

        guard
            let labelToHighlight = searchLabels.first(where: { $0?.text?.contains(search) ?? false }),
            let labelText = labelToHighlight?.text
        else { return }

        let attributedString = NSMutableAttributedString(string: labelText)
        let searchRange = (labelText.lowercased() as NSString).range(of: search.lowercased(), options: [.numeric])
        let highlightColor = UIColor.systemYellow.withAlphaComponent(0.5)
        attributedString.addAttribute(.backgroundColor, value: highlightColor, range: searchRange)
        labelToHighlight?.attributedText = attributedString
    }
}
