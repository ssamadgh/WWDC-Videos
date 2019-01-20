//
//  AAPLCollectionViewLayoutAttributes.swift
//  TangramUI
//
//  Created by 黄伯驹 on 08/01/2018.
//  Copyright © 2018 黄伯驹. All rights reserved.
//

import UIKit

/// Custom Layout Attributes for the Layout.
class AAPLCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    /// If this is a header, is it pinned to the top of the collection view?
    var isPinnedHeader = false
    /// The background color for the view
    var backgroundColor: UIColor?
    /// The background color when selected
    var selectedBackgroundColor: UIColor?
    /// Layout margins passed to cells and supplementary views
    var layoutMargins: UIEdgeInsets = .zero
}
