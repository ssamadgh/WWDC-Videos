/*
See LICENSE folder for this sample’s licensing information.

Abstract:
AchievementsCell uses Auto Layout standard spacing (system spacing) constraints.
 These allow constraining the baseline of a text-containing view
 to another view such that the spacing scales with the font in the text-containing view.
*/

import UIKit

class AchievementsCell: UITableViewCell {
    
    private let badgeImageView = UIImageView()
    private let badgeDescription = UILabel()
    private let padding: CGFloat = 10
    private var achievementString = ""
    
    private let imageToTextPadding: CGFloat = 8
    private let verticalPadding: CGFloat = 10
    
    private var commonConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var largeTextConstraints: [NSLayoutConstraint] = []
    private var imageCenterYConstraint: NSLayoutConstraint!
    
    var achievement: Achievement? {
        didSet {
            if let achievement = achievement {
                achievementString = achievement.achievementString
                badgeImageView.image = achievement.badgeImage
                badgeImageView.tintColor = achievement.badgeColor
                updateBadgeDescription()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(badgeImageView)
        contentView.addSubview(badgeDescription)
        
        setupLabelAndImageView()
        setupLayoutConstraints()
    }
    
    private func setupLabelAndImageView() {
        badgeDescription.font = UIFont.preferredFont(forTextStyle: .body)
        badgeDescription.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for:.horizontal)

        badgeImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true

        badgeDescription.numberOfLines = 0
        
    }
    
    private func setupLayoutConstraints() {
        commonConstraints = [
            badgeImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            badgeDescription.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            badgeDescription.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            badgeDescription.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ]
        regularConstraints = [
            badgeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeDescription.leadingAnchor.constraint(equalTo: badgeImageView.trailingAnchor, constant: imageToTextPadding)
        ]
        
        let labelHalfCapHeight = badgeDescription.font.capHeight / 2
        imageCenterYConstraint = badgeImageView.centerYAnchor.constraint(equalTo: badgeDescription.firstBaselineAnchor, constant: -labelHalfCapHeight)
        largeTextConstraints = [
            imageCenterYConstraint,
            badgeDescription.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        ]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            updateLayoutConstraints()
            updateBadgeDescription()
        }
    }
    
    private func updateLayoutConstraints() {
        NSLayoutConstraint.activate(commonConstraints)
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            NSLayoutConstraint.deactivate(regularConstraints)
            imageCenterYConstraint.constant = -badgeDescription.font.capHeight / 2
            NSLayoutConstraint.activate(largeTextConstraints)
        } else {
            NSLayoutConstraint.deactivate(largeTextConstraints)
            NSLayoutConstraint.activate(regularConstraints)
            
        }
    }
    
    /// - Tag: firstLineHeadIndent
    func updateBadgeDescription() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(NSParagraphStyle.default)

        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            badgeImageView.sizeToFit()
            paragraphStyle.firstLineHeadIndent = badgeImageView.frame.size.width + padding
        }
        let attributedString = NSAttributedString(string: achievementString,
                                                  attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle,
                                                               NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)])
        badgeDescription.attributedText = attributedString
    }
    
}
