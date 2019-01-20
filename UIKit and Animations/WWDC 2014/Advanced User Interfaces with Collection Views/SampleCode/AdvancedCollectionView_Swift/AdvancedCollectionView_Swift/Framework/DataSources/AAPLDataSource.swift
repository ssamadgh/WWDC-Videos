/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The base data source class.
*/

import UIKit

extension Array where Element: Equatable {
    
    @discardableResult
    mutating func remove(object: Element) -> Bool {
        if let index = index(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.index(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
}


/**
The AAPLDataSource class is a concrete implementation of the `UICollectionViewDataSource` protocol designed to support composition and sophisticated layout delegated to individual sections of the data source.

At a minimum, subclasses should implement the following methods for managing items:

- -numberOfSections
- -itemAtIndexPath:
- -indexPathsForItem:
- -removeItemAtIndexPath:
- -numberOfItemsInSection:

Subclasses should implement `-registerReusableViewsWithCollectionView:` to register their views for cells. Note, calling super is mandatory to ensure all views for headers and footers are properly registered. For example:

-(void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
[super registerReusableViewsWithCollectionView:collectionView];
[collectionView registerCell:[MyCell class] forCellWithReuseIdentifier:AAPLReusableIdentifierFromClass(MyCell)];
}

Subclasses will need to implement the `UICollectionView` data source method `-collectionView:cellForItemAtIndexPath:` to return a configured cell. For example:

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
MyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AAPLReusableIdentifierFromClass(MyCell) forIndexPath:indexPath];
MyItem *item = [self itemAtIndexPath:indexPath];
// ... configure the cell with the item
return cell;
}

For subclasses that need to load their content, implementing `-loadContentWithProgress:` is the answer. This method will always be called as the data source transitions from the initial state (`AAPLLoadState.initial`) to the content loaded state (`AAPLLoadStateContentLoaded`). The default implementation simply calls the complete method on the progress object to transition into the content loaded state. Subclasses can implement more complex loading logic. For example:

-(void)loadContentWithProgress:(AAPLLoadingProgress *)progress
{
[ServerManager fetchMyItemsWithCompletionHandler:^(NSArray<MyItem *> *items, NSError *error) {
if (progress.cancelled)
return;

if (error) {
[progress completeWithError:error];
return;
}

// It's important to only reference the data source via the parameter to prevent creation of retain cycles
[progress updateWithContent:^(MyDataSource *me) {
// store the items
}];
}];
}

*/


let AAPLReusableIdentifierFromClass: (UIView.Type) -> String = { "\($0)" }


class AAPLDataSource<ItemType>: NSObject, UICollectionViewDataSource {

    /// The title of this data source. This value is used to populate section headers and the segmented control tab.
    open var title: String?

    /// The number of sections in this data source.
	open var numberOfSections: Int {
        return 1
    }

    /// Return the number of items in a specific section. Implement this instead of the UICollectionViewDataSource method.
    open func numberOfItems(in sectionIndex: Int) -> Int {
        return 0
    }
    
    /// Find the data source for the given section. Default implementation returns self.
    open func dataSourceForSection(at sectionIndex: Int) -> AAPLDataSource {
        return self
    }
    
    /// Find the item at the specified index path. Returns nil when indexPath does not specify a valid item in the data source.
    open func item(at indexPath: IndexPath) -> ItemType? {
        return nil
    }
    
    /// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
    open func indexPaths(for item: ItemType) -> [IndexPath]? {
        return nil
    }
    
    /// Remove an item from the data source. This method should only be called as the result of a user action, such as tapping the "Delete" button in a swipe-to-delete gesture. Automatic removal of items due to outside changes should instead be handled by the data source itself — not the controller. Data sources must implement this to support swipe-to-delete.
    open func removeItem(at indexPath: IndexPath) {}
    
    /// The primary actions that may be performed on the item at the given indexPath. These actions may change depending on the state of the item, therefore, they should not be cached except during presentation. These actions are shown on the right side of the cell. Default implementation returns an empty array.
    open func primaryActionsForItem(at indexPath: IndexPath) -> [AAPLAction] {
        return []
    }
    
    /// Secondary actions that may be performed on the item at an index path. These actions may change depending on the state of the item, therefore, they should not be cached except during presentation. These actions are shown on the left side of the cell. Default implementation returns an empty array.
    open func secondaryActionsForItem(at indexPath: IndexPath) -> [AAPLAction] {
        return []
    }
    
    /// Called when a data source becomes active in a collection view. If the data source is in the `AAPLLoadState.initial` state, it will be sent a `-loadContent` message.
    open func didBecomeActive() {

		let loadingState = self.loadingState
		
        if loadingState.isEqual(to: AAPLLoadState.initial) {
            setNeedsLoadContent()
            return
        }
        
        if shouldShowActivityIndicator {
            presentActivityIndicator(for: IndexSet())
            return
        }
        
        // If there's a placeholder, we assume it needs to be re-presented. This means the placeholder ivar must be cleared when the placeholder is dismissed.
        if let placeholder = placeholder {
            presentPlaceholder(placeholder, for: IndexSet())
        }
    }
    
    /// Called when a data source becomes inactive in a collection view
    open func willResignActive() {
        // We need to hang onto the placeholder, because dismiss clears it
        let placeholder = self.placeholder
        if placeholder != nil {
            dismissPlaceholder(for: IndexSet())
            self.placeholder = placeholder;
        }
    }
    
    /// Should this data source allow its items to be selected? The default value is true.
    var isAllowsSelection = true
    
    // MARK: - Notifications
    
    /// Update the state of the data source in a safe manner. This ensures the collection view will be updated appropriately.
    open func performUpdate(_ update: @escaping () -> Void, completion: (() -> Void)?) {
        // If this data source is loading, wait until we're done before we execute the update
        if loadingState.isEqual(to: AAPLLoadState.loadingContent) {
            
            enqueueUpdateBlock({ [weak self] in
                self?.performUpdate(update, completion: completion)
            })
            return
        }

        internalPerformUpdate(update, completion: completion)
    }
    
    func enqueueUpdateBlock(_ block: (() -> Void)?) {
        var update: (() -> Void)?

        if let pendingUpdateBlock = pendingUpdateBlock {
            let oldPendingUpdate = pendingUpdateBlock
            update = {
                oldPendingUpdate()
                block?()
            }
        } else {
            update = block
        }

        pendingUpdateBlock = update
    }
    
    /// Notify the parent data source and the collection view that new items have been inserted at positions represented by insertedIndexPaths.
    open func notifyItemsInserted(at indexPaths: [IndexPath]) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didInsertItemsAt: indexPaths)
    }

    /// Notify the parent data source and collection view that the items represented by removedIndexPaths have been removed from this data source.
    open func notifyItemsRemoved(at indexPaths: [IndexPath]) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didRemoveItemsAt: indexPaths)
    }

    /// Notify the parent data sources and collection view that the items represented by refreshedIndexPaths have been updated and need redrawing.
    open func notifyItemsRefreshed(at indexPaths: [IndexPath]) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didRefreshItemsAt: indexPaths)
    }

    /// Alert parent data sources and the collection view that the item at indexPath was moved to newIndexPath.
    open func notifyItemMoved(from indexPath: IndexPath, toIndexPaths newIndexPath: IndexPath) {
		delegate?.dataSource(self as! AAPLDataSource<Any>, didMoveItemAt: indexPath, toIndexPath: newIndexPath)
    }
    
    /// Notify parent data sources and the collection view that the sections were inserted.
    open func notifySectionsInserted(_ sections: IndexSet) {
    
    }

    /// Notify parent data sources and (eventually) the collection view that the sections were removed.
    open func notifySectionsRemoved(_ sections: IndexSet) {
    
    }

    /// Notify parent data sources and the collection view that the section at oldSectionIndex was moved to newSectionIndex.
    open func notifySectionMovedFrom(_ oldSectionIndex: Int, to newSectionIndex: Int) {
    
    }

    /// Notify parent data sources and ultimately the collection view the specified sections were refreshed.
    open func notifySectionsRefreshed(_ sections: IndexSet) {

    }
    
    /// Notify parent data sources and ultimately the collection view that the data in this data source has been reloaded.
    open func notifyDidReloadData() {
        
    }
    
    /// Update the supplementary view or views associated with the header's AAPLSupplementaryItem and invalidate the layout
    open func notifyContentUpdated(forHeader header: AAPLSupplementaryItem) {

    }

    /// Update the supplementary view or views associated with the footer's AAPLSupplementaryItem and invalidate the layout
    open func notifyContentUpdated(forFooter footer: AAPLSupplementaryItem) {
        let indexPaths = self.indexPaths(for: footer, header: false)

        notifyContentUpdatedForSupplementaryItem(footer, at: indexPaths, header: false)
    }
    

    // MARK: - Metrics
    
    /// The default metrics for all sections in this data source.
    open var defaultMetrics = AAPLSectionMetrics()
	
    /// The metrics for the global section (headers and footers) for this data source. This is only meaningful when this is the root or top-level data source.
    open var globalMetrics = AAPLSectionMetrics()

    /// Retrieve the layout metrics for a specific section within this data source.
    open func metricsForSection(at sectionIndex: Int) -> AAPLSectionMetrics? {
        return sectionMetrics[sectionIndex]
    }

    /// Store customised layout metrics for a section in this data source. The values specified in metrics will override values specified by the data source's defaultMetrics.
    open func setMetrics(_ metrics: AAPLSectionMetrics, forSectionAt sectionIndex: Int) {
        sectionMetrics[sectionIndex] = metrics
    }

    private var headersByKey: [String: AAPLSupplementaryItem] = [:]
	
    /// Look up a data source header by its key. These headers will appear before headers from section 0. Returns nil when the header with the given key can not be found.
    open func header(for key: String) -> AAPLSupplementaryItem? {
        return headersByKey[key]
    }

    /// Create a new header and append it to the collection of data source headers.
    open func newHeader(for key: String) -> AAPLSupplementaryItem {
        assert(headersByKey[key] == nil, "Attempting to add a header for a key that already exists: \(key)")

        let header = AAPLSupplementaryItem(kind: UICollectionElementKindSectionHeader)
        headersByKey[key] = header
        headers.append(header)
        return header
    }

    /// Remove a data source header specified by its key.
    open func removeHeader(for key: String) {
        let oldHeader = headersByKey[key]
        assert(oldHeader != nil, "Attempting to remove a header that doesn't exist: key = \(key)")

        headers.remove(object: oldHeader!)
        headersByKey.removeValue(forKey: key)
    }

    /// Replace a data source header specified by its key with a new header with the same key.
    open func replaceHeader(for key: String, with header: AAPLSupplementaryItem) {
        let oldHeader = headersByKey[key]
        assert(oldHeader != nil, "Attempting to replace a header that doesn't exist: key = \(key)")

        let headerIndex = headers.index(of: oldHeader!)
        headersByKey[key] = header
        headers[headerIndex!] = header
    }

    /** Create a header for each section in this data source.
     
     @note The configuration block for this header will be called once for each section in the data source.
     */
    var newSectionHeader: AAPLSupplementaryItem? {
        let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics

        let header = defaultMetrics?.newHeader as? AAPLDataSourceSupplementaryItem

        return header
    }

    /** Create a footer for each section in this data source.
     
     @note Like -newSectionHeader, the configuration block for this footer will be called once for each section in the data source.
     */
    var newSectionFooter: AAPLSupplementaryItem? {
        let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
        let footer = defaultMetrics?.newFooter as? AAPLDataSourceSupplementaryItem

        return footer
    }
    
    /// Create a new header for a specific section. This header will only appear in the given section.
    open func newHeaderForSection(at sectionIndex: Int) -> AAPLSupplementaryItem? {
        var metrics = sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics
        if metrics == nil {
            metrics = AAPLDataSourceSectionMetrics()
            sectionMetrics[sectionIndex] = metrics
        }

        return metrics?.newHeader
    }

    /// Create a new footer for a specific section. This footer will only appear in the given section.
    open func newFooterForSection(at sectionIndex: Int) -> AAPLSupplementaryItem? {
        var metrics = sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics
        if metrics == nil {
            metrics = AAPLDataSourceSectionMetrics()
            sectionMetrics[sectionIndex] = metrics
        }

        return metrics?.newFooter
    }
    
    // MARK: - Placeholders
    
    /// The placeholder to show when the data source is in the No Content state.
    open var noContentPlaceholder = AAPLDataSourcePlaceholder()

    /// The placeholder to show when the data source is in the Error state.
    open var errorPlaceholder = AAPLDataSourcePlaceholder()
    
    // MARK: - Subclass hooks
    
    /// Determine whether or not a cell is editable. Default implementation returns YES.
    open func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    /// Determine whether or not the cell is movable. Default implementation returns NO.
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }

	/// Determine whether an item may be moved from its original location to a proposed location. Default implementation returns NO.
	open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) -> Bool {
		return false
	}

    /// Called by the collection view to alert the data source that an item has been moved. The data source should update its contents.
	open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		fatalError("Should be implemented by subclasses")
	}

    /// Register reusable views needed by this data source
    open func registerReusableViews(with collectionView: UICollectionView) {
        let numberOfSections = self.numberOfSections

        let globalMetrics = snapshotMetricsForSection(at: AAPLGlobalSectionIndex)

        for headerMetrics in globalMetrics.headers {
            collectionView.register(headerMetrics.supplementaryViewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerMetrics.reuseIdentifier)
        }

        for sectionIndex in 0 ..< numberOfSections {

            let metrics = snapshotMetricsForSection(at: sectionIndex)

            for headerMetrics in metrics.headers {
                collectionView.register(headerMetrics.supplementaryViewClass,
                                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                        withReuseIdentifier: headerMetrics.reuseIdentifier)
            }

            for footerMetrics in metrics.footers {
                collectionView.register(footerMetrics.supplementaryViewClass,
                                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                        withReuseIdentifier: footerMetrics.reuseIdentifier)
            }
        }

        collectionView.register(AAPLCollectionPlaceholderView.self,
                                forSupplementaryViewOfKind: AAPLCollectionElementKindPlaceholder,
                                withReuseIdentifier: AAPLReusableIdentifierFromClass(AAPLCollectionPlaceholderView.self))
    }

    private lazy var stateMachine: AAPLLoadableContentStateMachine = {
        let stateMachine = AAPLLoadableContentStateMachine()
        stateMachine.delegate = self
        return stateMachine
    }()

    // MARK: - Content loading
    
    /// Signal that the datasource should reload its content
    open func setNeedsLoadContent() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadContent), object: nil)
        perform(#selector(loadContent))
    }

    /// Reset the content and loading state.
    open func resetContent() {
        resettingContent = true
        // This ONLY works because the resettingContent flag is set to YES. This will be checked in -missingTransitionFromState:toState: to decide whether to allow the transition.
        loadingState = AAPLLoadState.initial
        resettingContent = false
        
        // Content has been reset, if we're loading something, chances are we don't need it.
        loadingProgress?.isCancelled = true
    }

    /// Use this method to wait for content to load. The block will be called once the loadingState has transitioned to the ContentLoaded, NoContent, or Error states. If the data source is already in that state, the block will be called immediately.
    open func whenLoaded(_ block: @escaping () -> Void) {
        var complete: Int32 = 0
        
        let oldLoadingCompleteBlock = self.loadingCompletionBlock

        self.loadingCompletionBlock = {
            // Already called the completion handler
            if !OSAtomicCompareAndSwap32(0, 1, &complete) {
                return
            }

            // Call the previous completion block if there was one.
            oldLoadingCompleteBlock?()

            block()
        }
    }
    
    // MARK: - Private
    
    /// Create an instance of the placeholder view for this data source.
    private func dequeuePlaceholderView(for collectionView: UICollectionView, at indexPath: IndexPath) -> AAPLCollectionPlaceholderView {
        let placeholderView = collectionView.dequeueReusableSupplementaryView(ofKind: AAPLCollectionElementKindPlaceholder, withReuseIdentifier: AAPLReusableIdentifierFromClass(AAPLCollectionPlaceholderView.self), for: indexPath) as? AAPLCollectionPlaceholderView

        updatePlaceholderView(placeholderView!, forSectionAt: indexPath.section)

        return placeholderView!
    }
    
    /// Compute a flattened snapshot of the layout metrics associated with this and any child data sources.
    private var snapshotMetrics: [Int: AAPLDataSourceSectionMetrics] {
        let numberOfSections = self.numberOfSections
        var metrics: [Int: AAPLDataSourceSectionMetrics] = [:]

        let globalMetrics = snapshotMetricsForSection(at: AAPLGlobalSectionIndex)
        metrics[AAPLGlobalSectionIndex] = globalMetrics

        for sectionIndex in 0 ..< numberOfSections{
            let sectionMetrics = snapshotMetricsForSection(at: sectionIndex)
            metrics[sectionIndex] = sectionMetrics
        }

        return metrics
    }

    /// Create a flattened snapshop of the layout metrics for the specified section. This resolves metrics from parent and child data sources.
    private func snapshotMetricsForSection(at sectionIndex: Int) -> AAPLDataSourceSectionMetrics {

        let metrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
        metrics?.applyValues(from: sectionMetrics[sectionIndex]!)

        // The root data source puts its headers into the special global section. Other data sources put theirs into their 0 section.
        let rootDataSource = self.isRootDataSource
        if rootDataSource && AAPLGlobalSectionIndex == sectionIndex {
            metrics?.headers = headers
        }
        
        // Stash the placeholder in the metrics. This is really only used so we can determine the range of the placeholders.
        metrics?.placeholder = self.placeholder
        
        // We need to handle global headers and the placeholder view for section 0
        if sectionIndex == 0 {
            var headers: [AAPLSupplementaryItem] = []

            if !rootDataSource {
                headers.append(contentsOf: self.headers)
            }
            
            if let h = metrics?.headers {
                headers.append(contentsOf: h)
            }

            metrics?.headers = headers
        }

        return metrics!
    }
    
    /// Should an activity indicator be displayed while we're refreshing the content. Default is NO.
    private(set) var showsActivityIndicatorWhileRefreshingContent = false
    
    /// Will this data source show an activity indicator given its current state?
    private var shouldShowActivityIndicator: Bool {
        let loadingState = self.loadingState

        return (showsActivityIndicatorWhileRefreshingContent && loadingState.isEqual(to: AAPLLoadState.refreshingContent)) || loadingState.isEqual(to: AAPLLoadState.loadingContent)
    }

    private var placeholder: AAPLDataSourcePlaceholder?
	
    /// Will this data source show a placeholder given its current state?
    private var shouldShowPlaceholder: Bool {
        return placeholder != nil
    }

    private var loadingProgress: AAPLLoadingProgress?
	
    /// Load the content of this data source.
    @objc
    private func loadContent() {

		loadingState = Set([AAPLLoadState.initial, AAPLLoadState.loadingContent]).contains(loadingState as! AAPLLoadState) ? AAPLLoadState.loadingContent : AAPLLoadState.refreshingContent
        
        notifyWillLoadContent()

		let loadingProgress = AAPLLoadingProgress.loadingProgress { [weak self] (toState, error, update) in
            // The only time toState will be nil is if the progress was cancelled.
            guard let toState = toState else {
                return
            }
			self?.endLoadingContent(with: toState, error: error, update: {
                if let me = self {
                    update?(me)
                }
            })
        }

        // Tell previous loading instance it's no longer current and remember this loading instance
        loadingProgress.isCancelled = true
        self.loadingProgress = loadingProgress

        beginLoadingContent(with: loadingProgress)
    }

    /// The internal method which is actually called by loadContent. This allows subclasses to perform pre- and post-loading activities.
    private func beginLoadingContent(with progress: AAPLLoadingProgress) {
        loadContentWithProgress(progress)
    }

    private var pendingUpdateBlock: (() -> Void)?
	
    var loadingError: Error?
	
    /// The internal method called when loading is complete. Subclasses may implement this method to provide synchronisation of child data sources.
	private func endLoadingContent(with state: State, error: Error?, update: @escaping () -> Void) {
        loadingError = error
        loadingState = state

        let pendingUpdates = pendingUpdateBlock
        pendingUpdateBlock = nil
		
		self.performUpdate({
			pendingUpdates?()
			update()
		}, completion: nil)

        notifyContentLoaded(with: error)
    }
    
    /// Display an activity indicator for this data source. If sections is nil, display the activity indicator for the entire data source. The sections must be contiguous.
    private func presentActivityIndicator(for sections: IndexSet?) {
        let delegate = self.delegate
        let sections = sections ?? IndexSet(integersIn: 0...self.numberOfSections)
        internalPerformUpdate({
            if (sections as NSIndexSet).contains(in: NSRange(location: 0, length: self.numberOfSections))  {
                placeholder = AAPLDataSourcePlaceholder.placeholderWithActivityIndicator
            }
            // The data source can't do this itself, so the request is passed up the tree. Ultimately this will be handled by the collection view by passing it along to the layout.
            delegate?.dataSource(self as! AAPLDataSource<Any>, didPresentActivityIndicatorFor: sections)
        })
    }

    private func internalPerformUpdate(_ block: () -> Void, completion: (() -> Void)? = nil) {
        // If our delegate our delegate can handle this for us, pass it up the tree
        if let delegate = self.delegate {
			delegate.dataSource(self as! AAPLDataSource<Any>, performBatchUpdate: block, complete: completion)
        } else {
            block()
            completion?()
        }
    }
    
    /// Display a placeholder for this data source. If sections is nil, display the placeholder for the entire data source. The sections must be contiguous.
    private func presentPlaceholder(_ placeholder: AAPLDataSourcePlaceholder, for sections: IndexSet?) {
        let delegate = self.delegate

		let sections = sections ?? IndexSet(integersIn: 0...self.numberOfSections)

        internalPerformUpdate( {
			if (sections as NSIndexSet).contains(in: NSRange(location: 0, length: self.numberOfSections)) {
                self.placeholder = placeholder
            }
            
            // The data source can't do this itself, so the request is passed up the tree. Ultimately this will be handled by the collection view by passing it along to the layout.
            delegate?.dataSource(self as! AAPLDataSource<Any>, didPresentPlaceholderFor: sections)
        })
    }

    /// Dismiss a placeholder or activity indicator
    private func dismissPlaceholder(for sections: IndexSet) {
        let delegate = self.delegate

        internalPerformUpdate({
            // Clear the placeholder when the sections represents the entire range of sections in this data source.
            if (sections as NSIndexSet).contains(in: NSRange(location: 0, length: self.numberOfSections)) {
                self.placeholder = nil
            }

            // We need to pass this up the tree of data sources until it reaches the collection view, which will then pass it to the layout.
            delegate?.dataSource(self as! AAPLDataSource<Any>, didDismissPlaceholderFor: sections)
        })
    }

    /// Update the placeholder view for a given section.
    private func updatePlaceholderView(_ placeholderView: AAPLCollectionPlaceholderView, forSectionAt sectionIndex: Int) {
        var message: String?
        var title: String?
        var image: UIImage?
        
        // Handle loading and refreshing states
        if shouldShowActivityIndicator {
            placeholderView.showActivityIndicator(true)
            placeholderView.hidePlaceholderAnimated(true)
            return
        }
        
        // For other states, start by turning off the activity indicator
        placeholderView.showActivityIndicator(false)

        title = placeholder?.title
        message = placeholder?.message
        image = placeholder?.image

        if title != nil || message != nil || image  != nil {
            placeholderView.showPlaceholder(with: title, message: message, image: image, animated: true)
        } else {
            placeholderView.hidePlaceholderAnimated(true)
        }
    }

    /// State machine delegate method for notifying that the state is about to change. This is used to update the loadingState property.
    func stateWillChange() {
        willChangeValue(forKey: "loadingState")
    }

    /// State machine delegate method for notifying that the state has changed. This is used to update the loadingState property.
    func stateDidChange() {
        didChangeValue(forKey: "loadingState")
    }
    
    private var headers: [AAPLSupplementaryItem] = []
    private var sectionMetrics: [Int: AAPLSectionMetrics] = [:]

    /// Return the number of headers associated with the section.
    private func numberOfHeadersInSection(at sectionIndex: Int, includeChildDataSouces: Bool) -> Int {

        if AAPLGlobalSectionIndex == sectionIndex && isRootDataSource {
            return headers.count
        }

        let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
        var numberOfHeaders = defaultMetrics?.headers.count ?? 0

        if sectionIndex == 0 && !isRootDataSource {
            numberOfHeaders += headers.count
        }

        let sectionMetrics = self.sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics
        numberOfHeaders += (sectionMetrics?.headers.count ?? 0)

        return numberOfHeaders
    }

    /// Return the number of footers associated with the section.
    private func numberOfFootersInSection(at sectionIndex: Int, includeChildDataSouces: Bool) -> Int {
        let rootDataSource = isRootDataSource

        if AAPLGlobalSectionIndex == sectionIndex && rootDataSource {
            return 0
        }

        let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
        var numberOfFooters = defaultMetrics?.footers.count ?? 0

        if let sectionMetrics = self.sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics {
            numberOfFooters += sectionMetrics.footers.count
        }

        return numberOfFooters
    }
    
    /// Returns NSIndexPath instances any occurrences of the supplementary metrics in this data source. If the supplementary metrics are part of the default metrics for the data source, an NSIndexPath for each section will be returned. Returns an empty array if the supplementary metrics are not found.
    private func indexPaths(for supplementaryItem: AAPLSupplementaryItem, header: Bool) -> [IndexPath] {
        let rootDataSource = self.isRootDataSource
        let numberOfSections = self.numberOfSections
        var itemIndex: Int?
        
        let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
        
        if header {
            itemIndex = headers.index(of: supplementaryItem)
            if let itemIndex = itemIndex {
                let indexPath = rootDataSource ? IndexPath(index: itemIndex) : IndexPath(item: itemIndex, section: 0)
                return [indexPath]
            }
            
            let numberOfGlobalHeaders = headers.count

            itemIndex = defaultMetrics?.headers.index(of: supplementaryItem)
            if let itemIndex = itemIndex {
                var result: [IndexPath] = []
                
                // When the header is found in the default metrics, we need to create one NSIndexPath for each section
                for sectionIndex in 0 ..< numberOfSections {
                    var headerIndex = itemIndex
                    if sectionIndex == 0 && !rootDataSource {
                        headerIndex += numberOfGlobalHeaders
                    }

                    result.append(IndexPath(item: headerIndex, section: sectionIndex))
                }

                return result
            }
            
            let numberOfDefaultHeaders = defaultMetrics?.headers.count ?? 0

            var result: IndexPath?
            
            // If the supplementary metrics exist, it's in one of the section metrics. However, it **might** simply not exist.
            for (sectionIndex, sectionMetrics) in sectionMetrics.enumerated() {

                itemIndex = (sectionMetrics.value as? AAPLDataSourceSectionMetrics)?.headers.index(of: supplementaryItem) ?? 0

                guard let itemIndex = itemIndex else {
                    continue
                }
 
                var headerIndex = numberOfDefaultHeaders + itemIndex
                if sectionIndex == 0 && !rootDataSource {
                    headerIndex += numberOfGlobalHeaders
                }

                result = IndexPath(item: headerIndex, section: sectionIndex)
            }
            
            if let result = result {
                return [result]
            }
            return []
        } else {
            let numberOfGlobalFooters = 0

            itemIndex = defaultMetrics?.footers.index(of: supplementaryItem)
            if let itemIndex = itemIndex {
                var result: [IndexPath] = []

                // When the header is found in the default metrics, we need to create one NSIndexPath for each section
                for sectionIndex in 0 ..< numberOfSections {
                    var footerIndex = itemIndex
                    if sectionIndex == 0 && !rootDataSource {
                        footerIndex += numberOfGlobalFooters
                    }

                    result.append(IndexPath(item: footerIndex, section: sectionIndex))
                }
                return result
            }
            
            let numberOfDefaultFooters = defaultMetrics?.footers.count ?? 0
            
            var result: IndexPath?
            
            // If the supplementary metrics exist, it's in one of the section metrics. However, it **might** simply not exist.
            for (sectionIndex, sectionMetrics) in sectionMetrics.enumerated() {
                itemIndex = (sectionMetrics.value as? AAPLDataSourceSectionMetrics)?.footers.index(of: supplementaryItem) ?? 0
                guard let itemIndex = itemIndex else {
                    continue
                }

                var footerIndex = numberOfDefaultFooters + itemIndex
                if sectionIndex == 0 && !rootDataSource {
                    footerIndex += numberOfGlobalFooters
                }

                result = IndexPath(item: footerIndex, section: sectionIndex)
            }

            if let result = result {
                return [result]
            }
            return []
        }
    }
    
    /// The block will only be called if the supplementary item is found.
    private func findSupplementaryItem(for header: Bool, indexPath: IndexPath, usingBlock block: (AAPLDataSource, IndexPath, AAPLSupplementaryItem) -> Void) {
        let sectionIndex = (indexPath.count > 1 ? indexPath.section : AAPLGlobalSectionIndex)
        var itemIndex = (indexPath.count > 1 ? indexPath.item : (indexPath as NSIndexPath).index(atPosition: 0))

        let rootDataSource = isRootDataSource
        
        // We should only have the global section when we're also the root data source
        assert(AAPLGlobalSectionIndex != sectionIndex || rootDataSource, "Should only have a global section index when we're the root data source")

        if header {
            if AAPLGlobalSectionIndex == sectionIndex && rootDataSource {
                if itemIndex < headers.count {
                    block(self, indexPath, headers[itemIndex])
                }
                return
            }

            if 0 == sectionIndex && !rootDataSource {
                if itemIndex < headers.count {
                    return block(self, indexPath, headers[itemIndex])
                }
                // need to allow for the headers that were added from the "global" data source headers.
                itemIndex -= headers.count
            }

            // check for headers in the default metrics
            let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
            let headersCount = defaultMetrics?.headers.count ?? 0
            if itemIndex < headersCount {
                return block(self, IndexPath(item: itemIndex, section: sectionIndex), defaultMetrics!.headers[itemIndex])
            }

            itemIndex -= headersCount

            let sectionMetrics = self.sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics
            if itemIndex < sectionMetrics!.headers.count {
                return block(self, IndexPath(item: itemIndex, section: sectionIndex), sectionMetrics!.headers[itemIndex])
            }
        } else {
            // check for footers in the default metrics
            let defaultMetrics = self.defaultMetrics as? AAPLDataSourceSectionMetrics
            if itemIndex < defaultMetrics!.footers.count {
                return block(self, IndexPath(item: itemIndex, section: sectionIndex), defaultMetrics!.footers[itemIndex])
            }

            itemIndex -= defaultMetrics!.footers.count
            
            // There's no equivalent to the headers by key (yet)
            let sectionMetrics = self.sectionMetrics[sectionIndex] as? AAPLDataSourceSectionMetrics
            if itemIndex < sectionMetrics!.footers.count {
                return block(self, IndexPath(item: itemIndex, section: sectionIndex), sectionMetrics!.footers[itemIndex])
            }
        }
    }
    
    /// Get an index path for the data source represented by the global index path. This works with -dataSourceForSectionAtIndex:.
    private func localIndexPath(for globalIndexPath: IndexPath) -> IndexPath {
        return globalIndexPath
    }
    
    /// Is this data source the root data source? This depends on proper set up of the delegate property. Container data sources ALWAYS act as the delegate for their contained data sources.
    private var isRootDataSource: Bool {
        return self.delegate as? AAPLDataSource != nil
    }
    
    /// A delegate object that will receive change notifications from this data source.
    private var delegate: AAPLDataSourceDelegate?
    
    /// Notify the parent data source that this data source will load its content. Unlike other notifications, this notification will not be propagated past the parent data source.
    private func notifyWillLoadContent() {
        delegate?.dataSourceWillLoadContent(self as! AAPLDataSource<Any>)
    }

    private var loadingCompletionBlock: (() -> Void)?

    /// Notify the parent data source that this data source has finished loading its content with the given error (nil if no error). Unlike other notifications, this notification will not propagate past the parent data source.
    private func notifyContentLoaded(with error: Error?) {
        let loadingCompleteBlock = self.loadingCompletionBlock
        self.loadingCompletionBlock = nil
        loadingCompleteBlock?()

        delegate?.dataSource(self as! AAPLDataSource<Any>, didLoadContentWith: error!)
    }
    
    private func notifySectionsInserted(_ sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection = .none) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didInsert: sections, direction: direction)
    }

    private func notifySectionsRemoved(_ sections: IndexSet, direction: AAPLDataSourceSectionOperationDirection = .none) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didRemove: sections, direction: direction)
    }

    private func notifySectionMovedFrom(_ section: Int, to newSection: Int, direction: AAPLDataSourceSectionOperationDirection = .none) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didMove: section, toSection: newSection, direction: direction)
    }
    
    private func notifyContentUpdatedForSupplementaryItem(_ metrics: AAPLSupplementaryItem, at indexPaths: [IndexPath], header: Bool) {
        delegate?.dataSource(self as! AAPLDataSource<Any>, didUpdateSupplementaryItem: metrics, at: indexPaths, header: header)
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeholder != nil ? 0 : numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Should be implemented by subclasses")
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == AAPLCollectionElementKindPlaceholder {
            return dequeuePlaceholderView(for: collectionView, at: indexPath)
        }
        
        var header = false
        
        if kind == UICollectionElementKindSectionHeader {
            header = true
        } else if kind == UICollectionElementKindSectionFooter {
            header = false
        } else {
            return UICollectionReusableView()
        }
        
        var metrics: AAPLSupplementaryItem?
        var localIndexPath: IndexPath?
        var dataSource = self
        
        findSupplementaryItem(for: header, indexPath: indexPath) { (foundDataSource, foundIndexPath, foundMetrics) in
            dataSource = foundDataSource
            localIndexPath = foundIndexPath
            metrics = foundMetrics
        }

        guard let _metrics = metrics else {
            return UICollectionReusableView()
        }

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: _metrics.reuseIdentifier, for: indexPath)

        _metrics.configureView?(view, dataSource as! AAPLDataSource<Any>, localIndexPath!)

        return view
    }
    
    private var resettingContent = false
}

extension AAPLDataSource: AAPLContentLoading {
	
    var loadingState: State {
        get {
            // Don't cause the creation of the state machine just by inspection of the loading state.
			return self.stateMachine.currentState ?? AAPLLoadState.initial
        }
        set {
			if !newValue.isEqual(to: stateMachine.currentState!) {
                stateMachine.currentState = loadingState
            }
        }
    }

    func loadContentWithProgress(_ progress: AAPLLoadingProgress) {
        progress.done()
    }
}

extension AAPLDataSource: AAPLStateMachineDelegate {
	
	func stateWillChange(from fromState: State?, to toState: State) {
		// loadingState property isn't really Key Value Compliant, so let's begin a change notification
		willChangeValue(forKey: "loadingState")
	}
	
	func stateDidChange(from fromState: State?, to toState: State) {
		// loadingState property isn't really Key Value Compliant, so let's finish a change notification
		didChangeValue(forKey: "loadingState")
	}
	
	func shouldEnter(to state: State) -> Bool {
		return true
	}
	
	func didEnter(to state: State) {
		switch (state as! AAPLLoadState) {
		case .loadingContent:
			self.presentActivityIndicator(for: nil)
		case .noContent:
			self.presentPlaceholder(self.errorPlaceholder, for: nil)
		default:
			break
		}
	}
	
	func didExit(from state: State) {
		switch (state as! AAPLLoadState) {
		case .loadingContent:
			self.presentActivityIndicator(for: nil)
		case .noContent:
			self.presentPlaceholder(self.errorPlaceholder, for: nil)
		default:
			break
		}
	}
	
	
	func missingTransition(from fromState: State?, to toState: State?) -> State? {
		guard toState != nil else {
			return nil
		}
		
		if !resettingContent {
			return nil
		}
		
		if AAPLLoadState.initial.isEqual(to: toState!) {
			return toState!
		}
		
		// All other cases fail
		return nil
	}
	
}
