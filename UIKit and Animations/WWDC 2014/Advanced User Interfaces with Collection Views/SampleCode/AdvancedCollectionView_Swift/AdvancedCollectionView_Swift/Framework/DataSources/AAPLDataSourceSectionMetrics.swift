//
//  AAPLDataSourceSectionMetrics.swift
//  TangramUI
//
//  Created by 黄伯驹 on 2017/12/16.
//  Copyright © 2017年 黄伯驹. All rights reserved.
//

import UIKit

class AAPLDataSourceSupplementaryItem: AAPLSupplementaryItem {
    
}

class AAPLDataSourceSectionMetrics : AAPLSectionMetrics {
    var headers: [AAPLSupplementaryItem] = []
    var footers: [AAPLSupplementaryItem] = []

    /// Create a new header associated with a specific data source
    var newHeader: AAPLSupplementaryItem {
        let header = AAPLDataSourceSupplementaryItem(kind: UICollectionElementKindSectionHeader)
        if headers.isEmpty {
            headers = [header]
        } else {
            headers.append(header)
        }
        return header
    }

    /// Create a new footer associated with a specific data source.
    var newFooter: AAPLSupplementaryItem {
        let footer = AAPLDataSourceSupplementaryItem(kind: UICollectionElementKindSectionHeader)
        if footers.isEmpty {
            footers = [footer]
        } else {
            footers.append(footer)
        }
        return footer
    }
    
    // Only used while creating a snapshot. Only actually used for comparisons sake, so we don't care what it is.
    var placeholder: Any?
}
