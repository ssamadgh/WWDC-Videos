//
//  CustomCollectionViewCell.swift
//  SelfSizingCollectionView
//
//  Created by Compean on 08/01/15.
//  Copyright (c) 2015 Carlos Compean. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    var hasCreatedConstraints = false
    
    struct CONSTRAINT_CONSTANTS {
        static var width : CGFloat!
    }
    //@IBOutlet weak var textLabelWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        //textLabel.numberOfLines = 0
        
        //contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        print("iniciando")
        
    }
	
	init() {
		super.init(frame: CGRect.zero)
		        print("aca")

	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		print("o aca")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		//setTranslatesAutoresizingMaskIntoConstraints(false)
		//removeConstraints(constraints())
		print("aqui")
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
            textLabel.preferredMaxLayoutWidth = CONSTRAINT_CONSTANTS.width - 66
            //textLabel.addConstraint(NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CONSTRAINT_CONSTANTS.width - 40))
			contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CONSTRAINT_CONSTANTS.width - 10))
        }
        
        
        
//        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: textLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: 1, constant: 0))
//
//        contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.Baseline, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1, constant: 0))
//        
//        //addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 200))
//        
//        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[textLabel]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: ["textLabel":textLabel]))
//        print("creando constraints")
        
        
        
        
    }
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        var attr = layoutAttributes.copy() as UICollectionViewLayoutAttributes
//        var size = self.textLabel.sizeToFit()
//    }
//    
//    - (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    UICollectionViewLayoutAttributes *attr = [layoutAttributes copy];
//    CGSize size = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFLOAT_MAX)];
//    CGRect newFrame = attr.frame;
//    newFrame.size.height = size.height;
//    attr.frame = newFrame;
//    return attr;
//    }
    
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
//        print("size: \(layoutAttributes.size)")
//        return layoutAttributes
////        //var attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
////        //var size = label.sizeThatFits(CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFloat.max))
////        var size = textLabel.sizeThatFits(CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFloat.max + 12))
////        var frame = layoutAttributes.frame
////        frame.size = size
////        layoutAttributes.frame = frame
////        //attributes.size = size
////        return layoutAttributes
//    }
}
