/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ScoreBoardViewController represents a score card for a battle.
 This view controller uses manual layout, so it is unable to take advantage of Auto Layout standard spacing
 (system spacing) baseline-to-baseline constraints.
 UIFontMetrics can be used to scale point values directly for calculations.
 This allows the class to specify a  default height for each row (popularity, health, etc.) and have that height scale based on the user's
 content size category. This view controller has a design requirement where all content must fit on one screen without scrolling.
 As a result, adjustsFontSizeToFitWidth is utilized as a fallback to reduce the size of the text and prevent truncation.
 The glyphs in ScoreCardViewController use adjustsImageSizeForAccessibilityContentSizeCategory to scale images at the 5 largest text sizes.
*/

import UIKit

class ScoreCardViewController: UIViewController {
    
    var scorecardID: Int = 0
    lazy var matchName: UILabel = self.makeLabel(forTextStyle: .title1)
    
    let myPetImageView = UIImageView()
    let myColor = #colorLiteral(red: 0, green: 0.8, blue: 0, alpha: 1)
    lazy var myPopularityImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "popularity"), color: self.myColor)
    lazy var myPopularityLabel: UILabel = self.makeLabel(forTextStyle: .body)
    lazy var myHealthImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "health"), color: self.myColor)
    lazy var myHealthLabel: UILabel = self.makeLabel(forTextStyle: .body)
    lazy var myWinningImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "winnings"), color: self.myColor)
    lazy var myWinningLabel: UILabel = self.makeLabel(forTextStyle: .body)
    
    let opponentPetImageView = UIImageView()
    let opponentColor = #colorLiteral(red: 0.8, green: 0, blue: 0, alpha: 1)
    lazy var opponentPopularityImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "popularity"), color: self.opponentColor)
    lazy var opponentPopularityLabel: UILabel = self.makeLabel(forTextStyle: .body)
    lazy var opponentHealthImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "health"), color: self.opponentColor)
    lazy var opponentHealthLabel: UILabel = self.makeLabel(forTextStyle: .body)
    lazy var opponentWinningImage: UIImageView = self.makeImageView(withImage: #imageLiteral(resourceName: "winnings"), color: self.opponentColor)
    lazy var opponentWinningLabel: UILabel = self.makeLabel(forTextStyle: .body)
    
    override var title: String? {
        set {
            // Don't allow setting
        }
        get {
            return "Battle!"
        }
    }
    
    private func makeLabel(forTextStyle textStyle: UIFontTextStyle) -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        // If the label is multiline (e.g. numberOfLines == 0), adjustsFontSizeToFitWidth will also shrink text to fit the height
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = minimumScaleFactor
        label.font = UIFont.preferredFont(forTextStyle: textStyle)
        return label
    }
    
    private func makeImageView(withImage image: UIImage, color: UIColor) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = image
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.tintColor = color
        return imageView
    }
    
    private let topPadding: CGFloat = 15.0
    private let bottomPadding: CGFloat = 16.0
    private let imageToLabelPadding: CGFloat = 16.0
    private let petToPetPadding: CGFloat = 15.0
    private let columnSidePadding: CGFloat = 32.0
    private let columnMidPadding: CGFloat = 16.0
    private let rowToRowVerticalPadding: CGFloat = 5.0
    private let minimumScaleFactor: CGFloat = 0.1
    private let labelHeight: CGFloat = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myPet = PetDataSource.petList()[0]
        let opponentPet = PetDataSource.petList()[scorecardID]
        matchName.text = myPet.name + " vs. " + opponentPet.name
        matchName.textAlignment = .center
        myPetImageView.image = myPet.image
        opponentPetImageView.image = opponentPet.image
        
        myPopularityLabel.text = String(myPet.popularity)
        opponentPopularityLabel.text = String(opponentPet.popularity)
        myHealthLabel.text = String(myPet.health)
        opponentHealthLabel.text = String(opponentPet.health)
        myWinningLabel.text = String(myPet.winnings)
        opponentWinningLabel.text = String(opponentPet.winnings)
        
        view.addSubview(matchName)
        view.addSubview(myPetImageView)
        view.addSubview(opponentPetImageView)
        view.addSubview(myPopularityImage)
        view.addSubview(myPopularityLabel)
        view.addSubview(opponentPopularityImage)
        view.addSubview(opponentPopularityLabel)
        view.addSubview(myHealthImage)
        view.addSubview(myHealthLabel)
        view.addSubview(opponentHealthImage)
        view.addSubview(opponentHealthLabel)
        view.addSubview(myWinningImage)
        view.addSubview(myWinningLabel)
        view.addSubview(opponentWinningImage)
        view.addSubview(opponentWinningLabel)
    }
    
    private func evaluateFrame(fromMaxY currentMaxY: CGFloat, forImageFrame imageFrame: CGRect) -> CGRect {
        var frame = imageFrame
        frame.origin.x = columnSidePadding
        frame.origin.y = currentMaxY + UIFontMetrics(forTextStyle: .body).scaledValue(for: rowToRowVerticalPadding)
        return frame
    }
    
    private func evaluateScoreLabelFrame(fromImageViewFrame imageViewFrame: CGRect) -> CGRect {
        var frame = imageViewFrame
        frame.origin.x = frame.maxX + imageToLabelPadding
        let availableWidthForAllContent = view.bounds.size.width - view.layoutMargins.left - view.layoutMargins.right
        let availableWidthForBothColumns = availableWidthForAllContent - ( 2 * columnSidePadding ) - columnMidPadding
        let availableWidthPerColumn = availableWidthForBothColumns / 2
        let availableWidthForLabel = availableWidthPerColumn - imageViewFrame.size.width
        frame.size.width = availableWidthForLabel
        frame.size.height = UIFontMetrics(forTextStyle: .body).scaledValue(for: labelHeight)
        return frame
    }
    
    private func evaluateFrame(forLabel label: UILabel) -> CGRect {
        label.sizeToFit()
        var frame = label.frame
        frame.size.width = view.bounds.size.width - view.layoutMargins.left - view.layoutMargins.right
        frame.origin.x = ( view.bounds.size.width - frame.size.width ) / 2
        return frame
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame = evaluateFrame(forLabel: matchName)
        frame.origin.y = view.layoutMargins.top + topPadding
        matchName.frame = frame
        
        myPopularityImage.sizeToFit()
        frame = evaluateFrame(fromMaxY: matchName.frame.maxY, forImageFrame: myPopularityImage.frame)
        myPopularityImage.frame = frame
        let startingXForOpponentImages = view.frame.origin.x + ( view.frame.size.width / 2 ) + ( columnMidPadding / 2 )
        frame.origin.x = startingXForOpponentImages
        opponentPopularityImage.frame = frame
        
        frame = evaluateFrame(fromMaxY: myPopularityImage.frame.maxY, forImageFrame: frame)
        myHealthImage.frame = frame
        frame.origin.x = startingXForOpponentImages
        opponentHealthImage.frame = frame
        
        frame = evaluateFrame(fromMaxY: myHealthImage.frame.maxY, forImageFrame: frame)
        myWinningImage.frame = frame
        frame.origin.x = startingXForOpponentImages
        opponentWinningImage.frame = frame
        
        myPopularityLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: myPopularityImage.frame)
        opponentPopularityLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: opponentPopularityImage.frame)
        myHealthLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: myHealthImage.frame)
        opponentHealthLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: opponentHealthImage.frame)
        myWinningLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: myWinningImage.frame)
        opponentWinningLabel.frame = evaluateScoreLabelFrame(fromImageViewFrame: opponentWinningImage.frame)
        
        let availableWidthForPets = view.bounds.size.width - view.layoutMargins.left - view.layoutMargins.right - petToPetPadding
        let maxYForStatistics = max(max(myWinningLabel.frame.maxY, opponentWinningLabel.frame.maxY), myWinningImage.frame.maxY)
        let availableHeightForPets = view.bounds.maxY - view.layoutMargins.bottom - bottomPadding - maxYForStatistics
        let sizeForPet = min(availableWidthForPets / 2, availableHeightForPets)
        frame = myPetImageView.frame
        frame.origin.x = view.layoutMargins.left
        frame.size.width = sizeForPet
        frame.size.height = sizeForPet
        frame.origin.y = view.bounds.maxY - view.layoutMargins.bottom - bottomPadding - frame.size.height
        myPetImageView.frame = frame
        frame.origin.x = view.bounds.origin.x + view.bounds.size.width - view.layoutMargins.right - frame.size.width
        opponentPetImageView.frame = frame
    }
}
