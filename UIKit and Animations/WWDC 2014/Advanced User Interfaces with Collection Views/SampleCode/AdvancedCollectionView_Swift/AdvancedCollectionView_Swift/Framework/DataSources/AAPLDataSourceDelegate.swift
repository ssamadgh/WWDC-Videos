//
//  AAPLDataSourceDelegate.swift
//  TangramUI
//
//  Created by 黄伯驹 on 2017/12/17.
//  Copyright © 2017年 黄伯驹. All rights reserved.
//

import Foundation

protocol AAPLDataSourceDelegate: class {
    func dataSource(_ dataSource: AAPLDataSource<Any>, didInsertItemsAt indexPaths: [IndexPath])

    func dataSource(_ dataSource: AAPLDataSource<Any>, didRemoveItemsAt indexPaths: [IndexPath])

    func dataSource(_ dataSource: AAPLDataSource<Any>, didRefreshItemsAt indexPaths: [IndexPath])
    
    func dataSource(_ dataSource: AAPLDataSource<Any>, didMoveItemAt indexPath: IndexPath, toIndexPath newIndexPath: IndexPath)
    
    func dataSource(_ dataSource: AAPLDataSource<Any>, didInsert sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection)

    func dataSource(_ dataSource: AAPLDataSource<Any>, didRemove sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection)

    func dataSource(_ dataSource: AAPLDataSource<Any>, didMove section: Int, toSection newSection: Int, direction: AAPLDataSourceSectionOperationDirection)

    func dataSource(_ dataSource: AAPLDataSource<Any>, didRefresh sections: IndexSet)

    func dataSourceDidReloadData(_ dataSource: AAPLDataSource<Any>)

    func dataSource(_ dataSource: AAPLDataSource<Any>, performBatchUpdate update: () -> Void, complete: (() -> Void)?)

    /// If the content was loaded successfully, the error will be nil.
    func dataSource(_ dataSource: AAPLDataSource<Any>, didLoadContentWith error: Error)
    
    /// Called just before a datasource begins loading its content.
    func dataSourceWillLoadContent(_ dataSource: AAPLDataSource<Any>)

    /// Present an activity indicator. The sections must be contiguous.
    func dataSource(_ dataSource: AAPLDataSource<Any>, didPresentActivityIndicatorFor sections: IndexSet)

    /// Present a placeholder for a set of sections. The sections must be contiguous.
    func dataSource(_ dataSource: AAPLDataSource<Any>, didPresentPlaceholderFor sections: IndexSet)
    
    /// Remove a placeholder for a set of sections.
    func dataSource(_ dataSource: AAPLDataSource<Any>, didDismissPlaceholderFor sections: IndexSet)

    /// Update the view or views associated with supplementary item at given index paths
    func dataSource(_ dataSource: AAPLDataSource<Any>, didUpdateSupplementaryItem supplementaryItem: AAPLSupplementaryItem, at indexPaths: [IndexPath], header: Bool)
}
