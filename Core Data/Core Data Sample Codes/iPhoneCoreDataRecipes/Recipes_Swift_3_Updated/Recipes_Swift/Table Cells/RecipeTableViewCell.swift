/*
  RecipeTableViewCell.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 1/26/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
A table view cell that displays information about a Recipe.  It uses individual subviews of its content view to show the name, picture, description, and preparation time for each recipe.  If the table view switches to editing mode, the cell reformats itself to move the preparation time off-screen, and resizes the name and description fields accordingly.
*/


import UIKit

private let imageSize: CGFloat = 42.0
private let editingInset: CGFloat = 10.0
private let textLeftMargin: CGFloat = 8.0
private let textRightMargin: CGFloat = 5.0
private let prepTimeWidth: CGFloat = 80.0

class RecipeTableViewCell: UITableViewCell {

	var recipeImageView: UIImageView!
	var nameLabel: UILabel!
	var overviewLabel: UILabel!
	var prepTimeLabel: UILabel!
	
	//MARK: - Recipe set accessor
	var recipe: Recipe! {
		didSet {
			if recipe != oldValue {
				self.recipeImageView.image = recipe.thumbnailImage
				self.nameLabel.text = recipe.name != nil && !recipe.name!.isEmpty ? recipe.name! : "-"
				self.overviewLabel.text = recipe.overview != nil ? recipe.overview : "-"
				self.prepTimeLabel.text = recipe.prepTime != nil ? recipe.prepTime : "-"
			}
		}
	}
	

	var imageViewFrame: CGRect {
		if self.isEditing {
			return CGRect(x: editingInset, y: 0, width: imageSize, height: imageSize)
		}
		else {
			return CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
		}
	}
	
	var nameLabelFrame: CGRect {
		if self.isEditing {
			return CGRect(x: imageSize + editingInset + textLeftMargin, y: 4.0, width: self.contentView.bounds.size.width - imageSize - editingInset - textLeftMargin, height: 16.0)
		}
		else {
			return CGRect(x: imageSize + textLeftMargin, y: 4.0, width: self.contentView.bounds.size.width - imageSize - textRightMargin*2 - prepTimeWidth, height: 16.0)
		}
	}
	
	var descriptionLabelFrame: CGRect {
		if self.isEditing {
			return CGRect(x: imageSize + editingInset + textLeftMargin, y: 22.0, width: self.contentView.bounds.size.width - imageSize - editingInset - textLeftMargin, height: 16.0)
		}
		else {
			return CGRect(x: imageSize + textLeftMargin, y: 22.0, width: self.contentView.bounds.size.width - imageSize - textLeftMargin, height: 16.0)
		}
	}
	
	var prepTimeLabelFrame: CGRect {
		let contentViewBounds = self.contentView.bounds
		return CGRect(x: contentViewBounds.size.width - prepTimeWidth - textRightMargin, y: 4.0, width: prepTimeWidth, height: 16.0)
	}

	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		recipeImageView = UIImageView(frame: .zero)
		self.recipeImageView.contentMode = .scaleAspectFit
		self.contentView.addSubview(self.recipeImageView)
		
		self.overviewLabel = UILabel(frame: .zero)
		self.overviewLabel.font = UIFont.systemFont(ofSize: 12.0)
		self.overviewLabel.textColor = UIColor.darkGray
		self.overviewLabel.highlightedTextColor = .white
		self.contentView.addSubview(self.overviewLabel)
		
		self.prepTimeLabel = UILabel(frame: .zero)
		self.prepTimeLabel.textAlignment = .right
		self.prepTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
		self.prepTimeLabel.textColor = .white
		self.prepTimeLabel.minimumScaleFactor = 7.0
		self.prepTimeLabel.lineBreakMode = .byTruncatingTail
		self.contentView.addSubview(self.prepTimeLabel)
		
		self.nameLabel = UILabel(frame: .zero)
		self.nameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
		self.nameLabel.textColor = .black
		self.nameLabel.highlightedTextColor = .white
		self.contentView.addSubview(self.nameLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.recipeImageView.frame = self.imageViewFrame
		self.nameLabel.frame = self.nameLabelFrame
		self.overviewLabel.frame = self.descriptionLabelFrame
		self.prepTimeLabel.frame = self.prepTimeLabelFrame
		
		if self.isEditing {
			self.prepTimeLabel.alpha = 0.0
		}
		else {
			self.prepTimeLabel.alpha = 1.0
		}
	}
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
