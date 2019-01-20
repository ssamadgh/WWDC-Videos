/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Support for common stylistic elements in an application.
*/

import UIKit

struct AAPLTheme {
    /// A theme singleton.
    static let theme = AAPLTheme()

    /// Because many bits of code simply grab an instance of the AAPLTheme singleton, it's useful to be able to specify what class that singleton should be.
    static func setThemeClass(themeClass: AAPLTheme.Type) {
        
    }
    
    /// The standard font for section headers. Somewhat large. May be used in cells or elsewhere if you want a font that is the same as the section header font.
    var sectionHeaderFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    /// The small font for section headers. This is used for the small text in the right label on the standard AAPLSectionHeaderView.
    var sectionHeaderSmallFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .subheadline)
    }

    /// The large font used in the global header.
    var headerTitleFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    /// The smaller font used in the global header.
    var headerBodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
    
    /// The font used in action cells as used in the AAPLActionDataSource.
    var actionButtonFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }

    /// The font used in the swipe to edit buttons within AAPLCollectionViewCells.
    var cellActionButtonFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .subheadline)
    }

    /// The font used for body text in AAPLKeyValueCell and AAPLTextValueCell instances.
    var bodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }

    /// A smaller body font.
    var smallBodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .footnote)
    }

    /// A larger body font.
    var largeBodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
    
    /// A medium sized font for use in list items.
    var listBodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }

    /// A smaller body font for use in list items.
    var listDetailFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .footnote)
    }

    /// A smaller font for use in list items.
    var listSmallFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    /// Standard list item layout margins (default is 15pt on leading and trailing, 0 on top & bottom)
    var listLayoutMargins: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    }

    /// The layout margins for section headers. This may be overridden for individual headers. (default is 15pt on leading and trailing, 5pt on top & bottom)
    var sectionHeaderLayoutMargins: UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }

    /// The colour used when displaying a destructive action, whether in AAPLActionCell or AAPLCollectionViewCell swipe to edit actions.
    var destructiveActionColor: UIColor {
        return UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1)
    }

    /// The colours used when displaying non-destructive and non-primary actions in the AAPLCollectionViewCell swipe to edit actions.
    var alternateActionColors: [UIColor] {
        return [
            UIColor(red: 1, green: 0.584, blue: 0, alpha: 1),
            UIColor(white: 199/255.0, alpha: 1)
        ]
    }

    /// The background colour for the area containing a cells action buttons
    var cellActionBackgroundColor: UIColor {
        return UIColor(white: 235/255.0, alpha: 1)
    }

    /// The background colour for a cell when it is highlighted for selection (default is 235/255).
    var selectedBackgroundColor: UIColor {
        return UIColor(white: 235/255.0, alpha: 1)
    }

    /// A light grey background colour (default is 248/255).
    var lightGreyBackgroundColor: UIColor {
        return UIColor(white: 248/255.0, alpha: 1)
    }

    /// A medium grey background colour (default is 235/255).
    var greyBackgroundColor: UIColor {
        return UIColor(white: 235/255.0, alpha: 1)
    }

    /// A dark grey background colour (default is 199/255).
    var darkGreyBackgroundColor: UIColor {
        return UIColor(white: 199/255.0, alpha: 1)
    }

    /// The default background colour (white).
    var backgroundColor: UIColor {
        return .white
    }
    
    /// The colour for separator lines (204/255).
    var separatorColor: UIColor {
        return UIColor(white: 204/255.0, alpha: 1)
    }
    
    /// A medium grey colour for text (116/255).
    var mediumGreyTextColor: UIColor {
        return UIColor(white: 116/255.0, alpha: 1)
    }

    /// A lighter grey colour for text (172/255).
    var lightGreyTextColor: UIColor {
        return UIColor(white: 172/255.0, alpha: 1)
    }

    /// A darker grey colour for text (77/255).
    var darkGreyTextColor: UIColor {
        return UIColor(white: 77/255.0, alpha: 1)
    }

}
