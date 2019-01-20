//
//  AAPLCollectionViewLayout.swift
//  TangramUI
//
//  Created by 黄伯驹 on 08/01/2018.
//  Copyright © 2018 黄伯驹. All rights reserved.
//

import UIKit

let AAPLCollectionElementKindRowSeparator = "AAPLCollectionElementKindRowSeparator"
let AAPLCollectionElementKindColumnSeparator = "AAPLCollectionElementKindColumnSeparator"
let AAPLCollectionElementKindSectionSeparator = "AAPLCollectionElementKindSectionSeparator"
let AAPLCollectionElementKindGlobalHeaderBackground = "AAPLCollectionElementKindGlobalHeaderBackground"


class AAPLCollectionViewLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
    /// Any index paths that have been explicitly invalidated need to be remeasured.
    var invalidateMetrics = false
}

class AAPLLayoutInfo {
    
}

enum AAPLAutoScrollDirection: Int {
    case unknown = 0
    case up
    case down
    case left
    case right
}

class AAPLLayoutSupplementaryItem: AAPLSupplementaryItem {
    
}

class AAPLCollectionViewLayout: UICollectionViewLayout {
    
    struct flags {
        /// the data source has the snapshot metrics method
        var dataSourceHasSnapshotMetrics = true
        /// layout data becomes invalid if the data source changes
        var layoutDataIsValid = true
    }
    
    var _flags = flags()

    /// Is the layout in editing mode? Default is NO.
    var isEditing = false {
        didSet {
            if isEditing == oldValue { return }
            
            print("editing = \(isEditing)")

            _flags.layoutDataIsValid = false
            invalidateLayout()
        }
    }
    
    
    var layoutSize: CGSize = .zero
    
    /// Scroll direction isn't really supported, but it might be in the future. Always returns UICollectionViewScrollDirectionVertical.
    var scrollDirection: UICollectionViewScrollDirection {
        return .vertical
    }
    var scrollingSpeed: CGFloat = 0
    var scrollingTriggerEdgeInsets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
    var selectedItemIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    var sourceItemIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    var currentView: UIView?
    var currentViewCenter: CGPoint = .zero
    var panTranslationInCollectionView: CGPoint = .zero
    var displayLink: CADisplayLink?
    var autoscrollDirection: AAPLAutoScrollDirection = .unknown
    var autoscrollBounds: CGRect = .zero
    var dragBounds: CGRect = .zero
    var dragCellSize: CGSize = .zero
    
    var pinnableItems: [AAPLLayoutSupplementaryItem] = []
    var layoutInfo: AAPLLayoutInfo?
    var oldLayoutInfo: AAPLLayoutInfo?
    
    /// A dictionary mapping the section index to the AAPLDataSourceSectionOperationDirection value
    var updateSectionDirections: [Int: Int] = [:]
    var insertedIndexPaths: Set<IndexPath> = []
    var removedIndexPaths: Set<IndexPath> = []
    var reloadedIndexPaths: Set<IndexPath> = []
    var insertedSections: Set<Int> = []
    var removedSections: Set<Int> = []
    var reloadedSections: Set<Int> = []
    /// Dictionary of kind to array of index paths for additional index paths to delete during updates
    var additionalDeletedIndexPaths: [String: [IndexPath]] = [:]
    /// Dictionary of kind to array of index paths for additional index paths to insert during updates
    var additionalInsertedIndexPaths: [String: [IndexPath]] = [:]
    var contentOffsetDelta: CGPoint = .zero
    
//    #if !SUPPORTS_SELFSIZING
    /// A duplicate registry of all the cell & supplementary view class/nibs used in this layout. These will be used to create views while measuring the layout instead of dequeueing reusable views, because that causes consternation in UICollectionView.
    var shadowRegistrar = AAPLShadowRegistrar()
    /// Flag used to lock out multiple calls to -buildLayout which seems to happen when measuring cells and supplementary views.
    var buildingLayout = false
    /// The attributes being currently measured. This allows short-circuiting the lookup in several API methods.
    var measuringAttributes: AAPLCollectionViewLayoutAttributes?
    /// The collection view wrapper used while measuring views.
    var collectionViewWrapper: UIView?
    
    override init() {
        super.init()
        
        
    }

    
    func aapl_commonInitCollectionViewLayout() {
        register(AAPLCollectionViewSeparatorView.self, forDecorationViewOfKind: AAPLCollectionElementKindRowSeparator)
        register(AAPLCollectionViewSeparatorView.self, forDecorationViewOfKind: AAPLCollectionElementKindColumnSeparator)
        register(AAPLCollectionViewSeparatorView.self, forDecorationViewOfKind: AAPLCollectionElementKindSectionSeparator)
        register(AAPLCollectionViewSeparatorView.self, forDecorationViewOfKind: AAPLCollectionElementKindGlobalHeaderBackground)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - private
extension AAPLCollectionViewLayout {
    /// Start dragging a cell at the specified index path
    func beginDraggingItem(at indexPath: IndexPath) {
    
    }
    
    /// End dragging the current cell
    func endDragging() {
        
    }

    /// Cancel dragging
    func cancelDragging() {
        
    }
    
    /// drag the cell based on the information provided by the gesture recognizer
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    
    }
    
    // Data source delegate methods that are helpful for performing animation
    func dataSource(_ dataSource: AAPLDataSource<Any>, didInsertSections sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection) {
    
    }

    func dataSource(_ dataSource: AAPLDataSource<Any>, didRemoveSections sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection) {
        
    }

    func dataSource(_ dataSource: AAPLDataSource<Any>, didMoveSection section: Int, toSection newSection: Int, direction: AAPLDataSourceSectionOperationDirection) {
    
    }
    
    func canEditItem(at indexPath: IndexPath) -> Bool {
        return false
    }

    func canMoveItem(at indexPath: IndexPath) -> Bool {
        return false
    }
    
//    #if !SUPPORTS_SELFSIZING
    func measuredSize(for supplementaryItem: AAPLLayoutSupplementaryItem) -> CGSize {
        return .zero
    }

    func measuredSize(for cell: AAPLLayoutCell) -> CGSize {
        return .zero
    }
    
    func measuredSize(for placeholder: AAPLLayoutPlaceholder) -> CGSize {
        return .zero
    }
//    #endif
}

class AAPLLayoutCell {
    
}

class AAPLLayoutPlaceholder {
    
}

class AAPLCollectionViewSeparatorView : UICollectionReusableView {
    
}
