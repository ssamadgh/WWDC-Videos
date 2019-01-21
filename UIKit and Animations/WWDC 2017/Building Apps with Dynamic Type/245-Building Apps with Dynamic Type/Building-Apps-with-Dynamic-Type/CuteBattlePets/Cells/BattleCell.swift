/*
See LICENSE folder for this sample’s licensing information.

Abstract:
BattleCell uses Auto Layout standard spacing (system spacing) constraints.
 These allow constraining the baseline of a text-containing view
 to another view such that the spacing scales with the font in the text-containing view.
 Several labels in BattleCell use the Noteworthy font instead of the standard text style fonts.
 The developer is responsible for choosing an appropriate font at the default content size category (```UIContentSizeCategoryLarge```),
 and optionally, an appropriate text style whose metrics should be used for scaling.
 The ```UIFontMetrics``` class then scales the font for the user's content size category automatically.
*/

import UIKit

class BattleCell: UITableViewCell {
    
    private let petImage = UIImageView()
    private let petName = UILabel()
    private let petDescription = UILabel()
    let battleButton = UIButton()
    private var commonConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var largeTextConstraints: [NSLayoutConstraint] = []
    private let verticalAnchorConstant: CGFloat = 24.0
    private let horizontalAnchorConstant: CGFloat = 16.0
    var pet: Pet? {
        didSet {
            if let pet = pet {
                petName.text = pet.name
                petImage.image = pet.image
                petDescription.text = pet.specialPowers
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        setupLabelsAndButtons()
        
        contentView.addSubview(petImage)
        contentView.addSubview(petName)
        contentView.addSubview(petDescription)
        contentView.addSubview(battleButton)
        
        setupLayoutConstraints()
        updateLayoutConstraints()
    }
    
    private func setupLabelsAndButtons() {
        battleButton.setTitle("BATTLE", for: .normal)
        battleButton.setTitleColor(battleButton.tintColor, for: .normal)
        battleButton.backgroundColor = UIColor.clear
        battleButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        battleButton.layer.borderWidth = 1
        battleButton.layer.borderColor = battleButton.tintColor.cgColor
        battleButton.layer.cornerRadius = 8
        battleButton.translatesAutoresizingMaskIntoConstraints = false
        battleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        battleButton.titleLabel?.adjustsFontForContentSizeCategory = true
        battleButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        
        petImage.translatesAutoresizingMaskIntoConstraints = false
        
        petDescription.translatesAutoresizingMaskIntoConstraints = false
        
        if let font = UIFont(name: "Noteworthy", size: 16) {
            petDescription.font = UIFontMetrics.default.scaledFont(for: font)
        }
        
        petDescription.adjustsFontForContentSizeCategory = true
        petDescription.numberOfLines = 3
        
        if let font = UIFont(name: "Noteworthy", size: 20) {
            petName.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: font)
        }
        petName.adjustsFontForContentSizeCategory = true
        petName.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayoutConstraints() {
        let heightConstraint = petImage.heightAnchor.constraint(equalToConstant: 100)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        commonConstraints = [
            petImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            petImage.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: verticalAnchorConstant),
            petImage.widthAnchor.constraint(equalToConstant: 100),
            heightConstraint
        ]
        regularConstraints = [
            
            petImage.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -verticalAnchorConstant),
            
            petName.leadingAnchor.constraint(equalTo: petImage.trailingAnchor, constant: horizontalAnchorConstant),
            petName.topAnchor.constraint(equalTo: petImage.topAnchor),
            petName.trailingAnchor.constraint(equalTo: battleButton.leadingAnchor, constant: -horizontalAnchorConstant),
            
            petDescription.firstBaselineAnchor.constraintEqualToSystemSpacingBelow(petName.lastBaselineAnchor, multiplier: 1),
            
            petDescription.leadingAnchor.constraint(equalTo: petImage.trailingAnchor, constant: horizontalAnchorConstant),
            petDescription.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -verticalAnchorConstant),
            petDescription.trailingAnchor.constraint(equalTo: battleButton.leadingAnchor, constant: -horizontalAnchorConstant),
            
            battleButton.centerYAnchor.constraint(equalTo: petImage.centerYAnchor),
            battleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalAnchorConstant)
        ]
        
        largeTextConstraints = [
            petName.leadingAnchor.constraint(equalTo: petImage.leadingAnchor),
            petName.topAnchor.constraint(equalTo: petImage.bottomAnchor),
            petName.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            petDescription.firstBaselineAnchor.constraintEqualToSystemSpacingBelow(petName.lastBaselineAnchor, multiplier: 1),
            
            petDescription.leadingAnchor.constraint(equalTo: petImage.leadingAnchor),
            petDescription.bottomAnchor.constraint(equalTo: battleButton.topAnchor, constant: -verticalAnchorConstant),
            petDescription.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            battleButton.leadingAnchor.constraint(equalTo: petImage.leadingAnchor),
            battleButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -verticalAnchorConstant)
        ]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory != previousTraitCollection?.preferredContentSizeCategory.isAccessibilityCategory {
            updateLayoutConstraints()
        }
    }
    
    private func updateLayoutConstraints() {
        NSLayoutConstraint.activate(commonConstraints)
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(largeTextConstraints)
        } else {
            NSLayoutConstraint.deactivate(largeTextConstraints)
            NSLayoutConstraint.activate(regularConstraints)
            
        }
    }
}
