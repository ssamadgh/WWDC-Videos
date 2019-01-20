//
//  AAPLLayoutMetrics.swift
//  AdvancedCollectionView_Swift
//
//  Created by Seyed Samad Gholamzadeh on 10/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
Classes used to define the layout metrics.
*/

import UIKit

enum AAPLCellLayoutOrder: Int {
	case leftToRight, rightToLeft
}

typealias AAPLSupplementaryItemConfigurationBlock = ( _ view: UICollectionReusableView, _ dataSource: AAPLDataSource<Any>, _ indexPath: IndexPath) -> Void


/// Definition of how supplementary views should be created and presented in a collection view.
protocol AAPLSupplementaryItemProtocol: NSObjectProtocol {
	
	/// Should this supplementary view be displayed while the placeholder is visible?
	var isVisibleWhileShowingPlaceholder: Bool { get }
	
	/// Should this supplementary view be pinned to the top of the view when scrolling? Only valid for header supplementary views.
	var shouldPin: Bool { get }
	
	/// The height of the supplementary view. Default value is AAPLCollectionViewAutomaticHeight. Setting this property to a concrete value will prevent the supplementary view from being automatically sized.
	var height: CGFloat { get set }
	
	/// The estimated height of the supplementary view. To prevent layout glitches, this value should be set to the best estimation of the height of the supplementary view.
	var estimatedHeight: CGFloat { get set }
	
	/// Returns YES if the supplementary layout metrics has estimated height
	var hasEstimatedHeight: Bool { get }
	
	/// Either the height or the estimatedHeight
	var fixedHeight: CGFloat { get }

	init(kind: String)
	
	/// Should the supplementary view be hidden?
	var isHidden: Bool { get }
	
	/// Use top & bottom layoutMargin to adjust spacing of header & footer elements. Not all headers & footers adhere to layoutMargins. Default is UIEdgeInsetsZero which is interpretted by supplementary items to be their default values.
	var layoutMargins: UIEdgeInsets { get set }
	
	/// The class to use when dequeuing an instance of this supplementary view
	var supplementaryViewClass: AnyClass? { get set }
	
	/// The background color that should be used for this supplementary view. If not set, this will be inherited from the section.
	var backgroundColor: UIColor { get set }
	
	/// The background color shown when this header is selected. If not set, this will be inherited from the section. This will only be used when simulatesSelection is YES.
	var selectedBackgroundColor: UIColor { get set }
	
	/// The color to use for the background when the supplementary view has been pinned. If not set, this will be inherrited from the section's backgroundColor value.
	var pinnedBackgroundColor: UIColor { get set }
	
	/// The color to use when showing the bottom separator line (if shown). If not set, this will be inherited from the section.
	var separatorColor: UIColor { get set }
	
	/// The color to use when showing the bottom separator line if the supplementary view has been pinned. If not set, this will be inherited from the section's separatorColor value.
	var pinnedSeparatorColor: UIColor { get set }
	
	/// Should the header/footer show a separator line? The default value is NO. When shown, the separator will be shown using the separator color.
	var showsSeparator: Bool { get set }
	
	/// Should this header simulate selection highlighting like cells? The default value is NO.
	var simulatesSelection: Bool { get set }
	
	/// The represented element kind of this supplementary view. Default is UICollectionElementKindSectionHeader.
	var elementKind: String { get }
	
	/// Optional reuse identifier. If not specified, this will be inferred from the class of the supplementary view.
	var reuseIdentifier: String { get set }
	
	/// A block that can be used to configure the supplementary view after it is created.
	var configureView: AAPLSupplementaryItemConfigurationBlock? { get set }
	
	/// Add a configuration block to the supplementary view. This does not clear existing configuration blocks.
	func configure(with block: @escaping AAPLSupplementaryItemConfigurationBlock)
	
	/// Update these metrics with the values from another metrics.
	func applyValues(from metrics: AAPLSupplementaryItemProtocol?)
	
}


/// Definition of how a section within a collection view should be presented.
protocol AAPLSectionMetricsProtocol: NSObjectProtocol, NSCopying {
	
	/// The height of each row in the section. The default value is AAPLCollectionViewAutomaticHeight. Setting this property to a concrete value will prevent rows from being sized automatically using autolayout.
	var rowHeight: CGFloat { get set }
	
	/// The estimated height of each row in the section. The default value is 44pts. The closer the estimatedRowHeight value matches the actual value of the row height, the less change will be noticed when rows are resized.
	var estimatedRowHeight: CGFloat { get set }
	
	/// Number of columns in this section. Sections will inherit a default of 1 from the data source.
	var numberOfColumns: Int { get set }
	
	/// Padding around the cells for this section. The top & bottom padding will be applied between the headers & footers and the cells. The left & right padding will be applied between the view edges and the cells.
	var padding: UIEdgeInsets { get set }
	
	/// Layout margins for cells in this section. When not set (e.g. UIEdgeInsetsZero), the default value of the theme will be used, listLayoutMargins.
	var layoutMargins: UIEdgeInsets { get set }
	
	/// Should a column separator be drawn. Default is YES.
	var showsColumnSeparator: Bool { get set }
	
	/// Should a row separator be drawn. Default is NO.
	var showsRowSeparator: Bool { get set }
	
	/// Should separators be drawn between sections. Default is NO.
	var showsSectionSeparator: Bool { get set }
	
	/// Should the section separator be shown at the bottom of the last section. Default is NO.
	var showsSectionSeparatorWhenLastSection: Bool { get set }
	
	/// Insets for the separators drawn between rows (left & right) and columns (top & bottom).
	var separatorInsets: UIEdgeInsets { get set }
	
	/// Insets for the section separator drawn below this section
	var sectionSeparatorInsets: UIEdgeInsets { get set }
	
	/// The color to use for the background of a cell in this section
	var backgroundColor: UIColor { get set }
	
	/// The color to use when a cell becomes highlighted or selected
	var selectedBackgroundColor: UIColor { get set }

	
	/// The color to use when drawing the row separators (and column separators when numberOfColumns > 1 && showsColumnSeparator == YES).
	var separatorColor: UIColor { get set }

	
	/// The color to use when drawing the section separator below this section.
	var sectionSeparatorColor: UIColor { get set }

	
	/// How the cells should be laid out when there are multiple columns. The current default is AAPLCellLayoutOrderLeftToRight, but it SHOULD be AAPLCellLayoutLeadingToTrailing.
	var cellLayoutOrder: AAPLCellLayoutOrder { get set }
	
	/// The default theme that should be passed to cells & supplementary views. The default value is an instance of AAPLTheme.
	var theme: AAPLTheme { get set }
	
	/// Update these metrics with the values from another metrics.
	func applyValues(from metrics: AAPLSectionMetrics)
	
	/// Resolve any missing property values from the theme if possible.
	func resolveMissingValuesFromTheme()
	
}

