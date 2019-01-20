//
//  CustomTableViewCellWithTextView.swift
//  SelfSizingCollectionView
//
//  Created by Compean on 12/01/15.
//  Copyright (c) 2015 Carlos Compean. All rights reserved.
//

import UIKit

class CustomTableViewCellWithTextView: UICollectionViewCell {
    
    @IBOutlet weak var textView : UITextView!
    var hasCreatedConstraints = false

    
    struct CONSTRAINT_CONSTANTS {
        static var width : CGFloat!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func updateConstraints() {
        //        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        //        textLabel.removeFromSuperview()
        //        contentView.removeConstraints(contentView.constraints())
        //        contentView.addSubview(textLabel)
        super.updateConstraints()
        print("cell width \(frame.width)")
        if (!hasCreatedConstraints) {
            hasCreatedConstraints = true;
            if CONSTRAINT_CONSTANTS.width == nil {
                CONSTRAINT_CONSTANTS.width = frame.width
            }
            //textLabel.addConstraint(NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CONSTRAINT_CONSTANTS.width - 40))
			textView.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CONSTRAINT_CONSTANTS.width - 40))
			contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CONSTRAINT_CONSTANTS.width - 20))
        }
    }
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//            var attr = layoutAttributes.copy() as UICollectionViewLayoutAttributes
//            var size = textView.sizeThatFits(CGSize(width: CGRectGetWidth(layoutAttributes.frame), height: CGFloat.max))
//        var newFrame = attr.frame
//        newFrame.size.height = size.height
//        attr.frame = newFrame
//        return attr
//        
//        
//    }
	
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        print("size: \(layoutAttributes.size)")
        return layoutAttributes
        //        //var attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
        //        //var size = label.sizeThatFits(CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFloat.max))
        //        var size = textLabel.sizeThatFits(CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFloat.max + 12))
        //        var frame = layoutAttributes.frame
        //        frame.size = size
        //        layoutAttributes.frame = frame
        //        //attributes.size = size
        //        return layoutAttributes
    }
    
    

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
