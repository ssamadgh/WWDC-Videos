//
//  SimpleStockView.swift
//  SimpleStocks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol SimpleStockViewDataSource {
	func graphViewDailyTradeInfoCount(_ graphView: SimpleStockView) -> Int
	func graphView(_ graphView: SimpleStockView, tradeCountForMonth components: DateComponents) -> Int
	func graphViewSortedMonths(_ graphView: SimpleStockView) -> [DateComponents]
	func graphViewDailyTradeInfos(_ graphView: SimpleStockView) -> [DailyTradeInfo]
	func graphViewMaxClosingPrice(_ graphView: SimpleStockView) -> CGFloat
	func graphViewMinClosingPrice(_ graphView: SimpleStockView) -> CGFloat
	func graphViewMaxTradingVolume(_ graphView: SimpleStockView) -> CGFloat
	func graphViewMinTradingVolume(_ graphView: SimpleStockView) -> CGFloat
}

/*
* The view that draws the stock info.
*/
class SimpleStockView: UIView {

	var numberFormatter: NumberFormatter!
	var initialDataPoint: CGPoint!
	var dataSource: SimpleStockViewDataSource!

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// keep the number formatter around, they are expensive to create
		self.numberFormatter = NumberFormatter()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	/*
	* Creates and returns a path that can be used to clip drawing to the top
	* of the data graph.
	*/
	func topClipPathFromDataInRect(_ rect: CGRect) -> UIBezierPath {
		let path = UIBezierPath()
		path.append(self.pathFromDataInRect(rect))
		let currentPoint = path.currentPoint
		path.addLine(to: CGPoint(x: rect.maxX, y: currentPoint.y))
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
		path.addLine(to: CGPoint(x: rect.minX, y: initialDataPoint.y))
		path.addLine(to: CGPoint(x: initialDataPoint.x, y: initialDataPoint.y))
		path.close()
		return path
	}

	/*
	* Creates and returns a path that can be used to clip drawing to the bottom
	* of the data graph.
	*/
	func bottomClipPathFromDataInRect(_ rect: CGRect) -> UIBezierPath {
		let path = UIBezierPath()
		path.append(self.pathFromDataInRect(rect))
		let currentPoint = path.currentPoint
		path.addLine(to: CGPoint(x: rect.maxX, y: currentPoint.y))
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.minX, y: initialDataPoint.y))
		path.addLine(to: CGPoint(x: initialDataPoint.x, y: initialDataPoint.y))
		path.close()
		return path
	}
	
	/*
	* Draws the month names, reterived from the NSDateFormatter.
	*/
	func drawMonthNamesTextUnderDataRect(_ dataRect: CGRect, volumeGraphHeight: CGFloat) {
		let dataCount = self.dataSource.graphViewDailyTradeInfoCount(self)
		let sortedMonths = self.dataSource.graphViewSortedMonths(self)
		
		let calendar = Calendar.current
		
		let dateFormatter = DateFormatter()
		
		let format = DateFormatter.dateFormat(fromTemplate: "MMMM", options: 0, locale: Locale.current)
		dateFormatter.dateFormat = format
		
		UIColor.white.setFill()
		let font = UIFont.boldSystemFont(ofSize: 16.0)
		
		let ctx = UIGraphicsGetCurrentContext()

		ctx?.saveGState()
		let shadowHeight: CGFloat = 2.0
		
		ctx?.setShadow(offset: CGSize(width: 1.0, height: -shadowHeight), blur: 0.0, color: UIColor.darkGray.cgColor)
		let tradingDayLineSpacing = rint(dataRect.width/CGFloat(dataCount))
		
		for i in 0..<(sortedMonths.count - 1) {
			let linePosition = tradingDayLineSpacing * CGFloat(self.dataSource.graphView(self, tradeCountForMonth: sortedMonths[i]))
			ctx?.translateBy(x: linePosition, y: 0.0)
			let date = calendar.date(from: sortedMonths[i + 1])
			let monthName = dateFormatter.string(from: date!)
			let attrs = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor: UIColor.white]

			let monthNameAttributeString = NSAttributedString(string: monthName, attributes: attrs)
			let monthSize = monthNameAttributeString.size()
			let monthRect = CGRect(x: 0.0, y: dataRect.maxY + volumeGraphHeight + shadowHeight, width: ceil(monthSize.width), height: ceil(monthSize.height))
			print("xPosition: \(linePosition), month name: \(monthName)")
			monthNameAttributeString.draw(with: monthRect, options: .usesLineFragmentOrigin, context: nil)
		}
		ctx?.restoreGState()
	}
	
	//MARK: - Draw Closing Data
	
	/*
	* The path for the closing data, this is used to draw the graph, and as part of the
	* top and bottom clip paths.
	*/
	func pathFromDataInRect(_ rect: CGRect) -> UIBezierPath {
		let tradingDays = self.dataSource.graphViewDailyTradeInfoCount(self)
		let maxClose = self.dataSource.graphViewMaxClosingPrice(self)
		let minClose = self.dataSource.graphViewMinClosingPrice(self)
		let dailyTradeInfos = self.dataSource.graphViewDailyTradeInfos(self)

		let path = UIBezierPath()

		// even though this lineWidth is odd, we don't do any offset because its not going to
		// ever line up with any pixels, just think geometrically
		let lineWidth: CGFloat = 5.0
		path.lineWidth = lineWidth
		path.lineJoinStyle = .round
		path.lineCapStyle = .round

		// inset so the path does not ever go beyond the frame of the graph
		let rect = rect.insetBy(dx: lineWidth/2.0, dy: lineWidth)
		let horizontalSpacing = rect.width/CGFloat(tradingDays)
		let verticalScale = rect.height/(maxClose-minClose)
		var closingPrice = CGFloat(dailyTradeInfos[0].closingPrice.doubleValue)
		initialDataPoint = CGPoint(x: lineWidth/2.0, y: (closingPrice - minClose) * verticalScale)
		path.move(to: initialDataPoint)
		
		for i in 1..<(tradingDays-1) {
			closingPrice = CGFloat(dailyTradeInfos[i].closingPrice.doubleValue)
			path.addLine(to: CGPoint(x: CGFloat(i+1)*horizontalSpacing, y: rect.minY + (closingPrice - minClose) * verticalScale))
		}
		closingPrice = CGFloat(dailyTradeInfos.last!.closingPrice.doubleValue)
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (closingPrice - minClose) * verticalScale))

		return path
	}

	/*
	* Draws the path for the closing price data set.
	*/
	func drawClosingDataInRect(_ rect: CGRect) {
		UIColor.white.setStroke()
		let path = self.pathFromDataInRect(rect)
		path.stroke()
	}
	
	//MARK: - Draw Volume Data
	
	/*
	* Draws the vertical lines for the volume data set.
	*/
	func drawVolumeDataInRect(_ volumeGraphRect: CGRect) {
		let maxVolume = self.dataSource.graphViewMaxTradingVolume(self)
		let minVolume = self.dataSource.graphViewMinTradingVolume(self)
		let verticalScale = volumeGraphRect.height/(maxVolume - minVolume)

		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		let tradingDayLineSpacing = rint(volumeGraphRect.width/CGFloat(self.dataSource.graphViewDailyTradeInfoCount(self)))
		var counter: CGFloat = 0.0
		let maxY: CGFloat = volumeGraphRect.maxY
		UIColor.white.setStroke()
		
		let dailyTradeInfos = self.dataSource.graphViewDailyTradeInfos(self)
		for dailyTradeInfo in dailyTradeInfos {
			let path = UIBezierPath()
			path.lineWidth = 2.0
			let tradingVolume: CGFloat = CGFloat(dailyTradeInfo.tradingVolume.doubleValue)
			path.move(to: CGPoint(x: rint(counter*tradingDayLineSpacing), y: maxY))
			path.addLine(to: CGPoint(x: rint(counter*tradingDayLineSpacing), y: maxY - (tradingVolume - minVolume) * verticalScale))
			path.stroke()
			counter += 1.0
		}
		ctx?.restoreGState()
	}
	
	//MARK: - Draw Line Pattern
	
	/*
	* Draws the line pattern, slowly changing the alpha of the stroke color
	* from 0.8 to 0.2.
	*/
	func drawLinePatternUnderClosingData(_ rect: CGRect, shouldClip: Bool) {
		let ctx = UIGraphicsGetCurrentContext()
		if shouldClip {
			ctx?.saveGState()
			let clipPath = self.bottomClipPathFromDataInRect(rect)
			clipPath.addClip()
		}
		
		let path = UIBezierPath()
		let lineWidth: CGFloat = 1.0
		path.lineWidth = lineWidth
		
		// because the line width is odd, offset the horizontal lines by 0.5 points
		// rint(Double) method rounds the given number if is under x.5 to lower int num and if is abbove than x.5 to upper int num
		path.move(to: CGPoint(x: 0.0, y: rint(rect.minY + 0.5)))
		path.addLine(to: CGPoint(x: rint(rect.maxX), y: rect.minY + 0.5))
		var alpha: CGFloat = 0.8
		var startColor = UIColor(white: 1.0, alpha: alpha)
		startColor.setStroke()
		let step: CGFloat = 4.0
		let stepCount: CGFloat = rect.height/step
		
		// alpha starts at 0.8, ends at 0.2
		let alphaStep: CGFloat = (0.8 - 0.2)/stepCount
		ctx?.saveGState()
		var translation = rect.minY
		
		while translation<rect.maxY {
			path.stroke()
			ctx?.translateBy(x: 0.0, y: lineWidth*step)
			translation += lineWidth*step
			alpha -= alphaStep
			startColor = startColor.withAlphaComponent(alpha)
			startColor.setStroke()
		}
		ctx?.restoreGState()
		if shouldClip {
			ctx?.restoreGState()
		}
	}
	
	//MARK: - Pattern Drawing Methods
	
	/*
	* This method creates the blue gradient used behind the 'programmer art' pattern
	*/
	lazy var blueBlendGradient: CGGradient! = {
		let colors: [CGFloat] = [
			0.0, 80.0/255, 89.0/255.0, 1.0,
			0.0, 50.0/255, 64.0/255.0, 1.0,
		]
		let locations: [CGFloat] = [0.0, 0.9]
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let blueBlendGradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: 2)
		return blueBlendGradient

	}()
	
	/*
	* This method draws the line used behind the 'programmer art' pattern
	*/
	func drawLine(from start: CGPoint, to end: CGPoint) {
		let path = UIBezierPath()
		path.lineWidth = 2.0
		path.move(to: start)
		path.addLine(to: end)
		path.stroke()
	}
	
	/*
	* This method draws the blue gradient used behind the 'programmer art' pattern
	*/
	func drawRadialGradientInSize(_ size: CGSize, centeredAt center: CGPoint) {
		let ctx = UIGraphicsGetCurrentContext()
		let startRadius: CGFloat = 0.0
		let endRadius: CGFloat = 0.85 * pow(floor(size.width/2.0) * floor(size.width/2.0) + floor(size.height/2.0) * floor(size.height/2.0), 0.5)
		ctx?.drawRadialGradient(self.blueBlendGradient, startCenter: center, startRadius: startRadius, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
	}
	
	/*
	* This method creates a UIImage from the 'programmer art' pattern
	*/
	func patternImageOfSize(_ size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
		
		let center = CGPoint(x: floor(size.width/2.0), y: floor(size.height/2.0))
		self.drawRadialGradientInSize(size, centeredAt: center)
		let lineColor = UIColor(red: 211.0/255.0,
								green: 218.0/255.0,
								blue: 182.0/255.0,
								alpha: 1.0)
		lineColor.setStroke()
		
		var start = CGPoint.zero
		var end = CGPoint(x: floor(size.width), y: floor(size.height))
		self.drawLine(from: start, to: end)
		
		start = CGPoint(x: 0.0, y: floor(size.height))
		end = CGPoint(x: floor(size.width), y: 0.0)
		self.drawLine(from: start, to: end)
		
		let patternImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return patternImage
	}

	
	/*
	* draws the 'programmer art' pattern under the closing data graph
	*/
	func drawPatternUnderClosingData(_ rect: CGRect, shouldClip: Bool) {
		UIColor(patternImage: self.patternImageOfSize(CGSize(width: 32.0, height: 32.0))).setFill()
		if shouldClip {
			let path = self.bottomClipPathFromDataInRect(rect)
			path.fill()
		}
		else {
			UIRectFill(rect)
		}
	}
	
	//MARK: - Draw Horizontal Grid
	
	/*
	* draws the horizontal lines that make up the grid
	* if shouldClip then it will clip to the data
	* if not then it won't
	* shouldClip is a debugging tool, pass YES most of the time
	*/
	func drawHorizontalGridInRect(_ dataRect: CGRect, shouldClip: Bool) {
		let ctx = UIGraphicsGetCurrentContext()
		if shouldClip {
			ctx?.saveGState()
			let clipPath = self.topClipPathFromDataInRect(dataRect)
			clipPath.addClip()
		}
		
		let path = UIBezierPath()
		path.lineWidth = 1.0
		path.move(to: CGPoint(x: rint(dataRect.minX), y: rint(dataRect.minY) + 0.5))
		path.addLine(to: CGPoint(x: rint(dataRect.maxX), y: rint(dataRect.minY) + 0.5))
		let dashPatern: [CGFloat] = [1.0, 1.0]
		path.setLineDash(dashPatern, count: 2, phase: 0.0)
		let gridColor = UIColor(red: 74.0/255.0, green: 86.0/255.0, blue: 126.0/266.0, alpha: 1.0)
		gridColor.setStroke()
		
		ctx?.saveGState()
		path.stroke()
		
		for _ in 0..<5 {
			ctx?.translateBy(x: 0.0, y: rint(dataRect.height)/5.0)
			path.stroke()
		}
		ctx?.restoreGState()
		if shouldClip {
			ctx?.restoreGState()
		}
	}
	
	//MARK: - Draw Vertical Grid
	
	/*
	* Draws the vertical grid that sits behind the data
	* makes sure not to step into the space needed by the
	* volume graph and the price labels
	*/
	func drawVerticalGridInRect(_ dataRect: CGRect, volumeGraphHeight: CGFloat, priceLabelWidth: CGFloat) {
		let gridColor = UIColor(red: 74.0/255.0, green: 86.0/255.0, blue: 126.0/266.0, alpha: 1.0)
		gridColor.setStroke()
		let dataCount = self.dataSource.graphViewDailyTradeInfoCount(self)
		let sortedMonths = self.dataSource.graphViewSortedMonths(self)
		
		let gridLinePath = UIBezierPath()
		gridLinePath.move(to: CGPoint(x: rint(dataRect.minX), y: rint(dataRect.minY)))
		gridLinePath.addLine(to: CGPoint(x: rint(dataRect.minX), y: rint(dataRect.maxY) + volumeGraphHeight))
		gridLinePath.lineWidth = 2.0
		
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		
		// round to an integer point
		let tradingDayLineSpacing: CGFloat = rint(dataRect.width)/CGFloat(dataCount)
		for i in 0..<(sortedMonths.count - 1) {
			let linePosition = tradingDayLineSpacing * CGFloat(self.dataSource.graphView(self, tradeCountForMonth: sortedMonths[i]))
			ctx?.translateBy(x: rint(linePosition), y: 0.0)
			gridLinePath.stroke()
		}
		
		ctx?.restoreGState()
		ctx?.saveGState()
		ctx?.translateBy(x: dataRect.maxX, y: 0.0)
		gridLinePath.stroke()
		ctx?.restoreGState()
		
		let horizontalLine = UIBezierPath()
		horizontalLine.move(to: CGPoint(x: rint(dataRect.minX), y: rint(dataRect.maxY)))
		horizontalLine.addLine(to: CGPoint(x: rint(dataRect.maxX) + priceLabelWidth, y: rint(dataRect.maxY)))
		horizontalLine.lineWidth = 2.0
		horizontalLine.stroke()
		ctx?.saveGState()
		ctx?.translateBy(x: 0.0, y: rint(volumeGraphHeight))
		horizontalLine.stroke()
		ctx?.restoreGState()
	}
	
	//MARK: - Background Gradient
	/*
	* Creates the blue background gradient
	*/
	lazy var backgroundGradient: CGGradient! = {
		// lazily create the gradient, then reuse it

		let colors: [CGFloat] = [48.0 / 255.0, 61.0 / 255.0, 114.0 / 255.0, 1.0,
				33.0 / 255.0, 47.0 / 255.0, 113.0 / 255.0, 1.0,
				20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0,
				20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0 ]
		let colorsStops: [CGFloat] = [0.0, 0.5, 0.5, 1.0]
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let backgroundGradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: colorsStops, count: 4)
		return backgroundGradient
	}()
	
	/*
	* draws the blue background gradient
	*/
	func drawBackgroundGradient() {
		let ctx = UIGraphicsGetCurrentContext()
		let startPoint = CGPoint.zero
		let endPoint = CGPoint(x: 0.0, y: self.bounds.size.height)
		ctx?.drawLinearGradient(self.backgroundGradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
	}
	
	//MARK: - Layout Calculations
	var priceLabelWidth: CGFloat {
		// tweaked till it looked good
		let minimum: CGFloat = 32.0
		let maximum: CGFloat = 54.0
		let number: NSNumber = NSNumber(value: Double(self.dataSource.graphViewMaxClosingPrice(self)))
		let attr: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
		let size: CGSize = numberFormatter.string(from: number)!.size(withAttributes: attr)
		var width = minimum
		if size.width < maximum && size.width >  minimum {
			width = size.width
		}
		return width
	}
	
	var volumeGraphHeight: CGFloat {
		// tweaked till it looked good, should be doing something a bit more scientific
		return 37.0
	}
	
	var closingDataRect: CGRect {
		let top: CGFloat = 57.0 // => text height + button height
		let textHeight: CGFloat = 25.0
		let bottom: CGFloat = self.bounds.size.height - (textHeight + self.volumeGraphHeight)

		let left: CGFloat = 0.0
		let right: CGFloat = self.bounds.width - self.priceLabelWidth

		return CGRect(x: left, y: top, width: right, height: bottom - top)
	}
	
	var volumeDataRect: CGRect {
		let textHeight: CGFloat = 25.0
		let bottom = self.bounds.size.height - (textHeight + self.volumeGraphHeight)

		let left: CGFloat = 0.0
		let right: CGFloat = self.bounds.width - self.priceLabelWidth

		return CGRect(x: left, y: bottom, width: right, height: self.volumeGraphHeight)
	}
	
	/*
	* The instigating method for drawing the graph
	* clips to the rounded rect
	* draws the components
	*/
    override func draw(_ rect: CGRect) {
        // Drawing code
		let dataRect = self.closingDataRect
		let volumeRect = self.volumeDataRect

		// clip to the rounded rect
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 16.0, height: 16.0))
		path.addClip()
		self.drawBackgroundGradient()
		self.drawVerticalGridInRect(dataRect, volumeGraphHeight: volumeRect.height, priceLabelWidth: self.priceLabelWidth)
		self.drawHorizontalGridInRect(dataRect, shouldClip: true)
		self.drawPatternUnderClosingData(dataRect, shouldClip: true)
		self.drawLinePatternUnderClosingData(dataRect, shouldClip: true)
		self.drawVolumeDataInRect(volumeRect)
		self.drawClosingDataInRect(dataRect)
		self.drawMonthNamesTextUnderDataRect(dataRect, volumeGraphHeight: self.volumeGraphHeight)
//		self.drawBeachUnderDataInRect(dataRect)
    }
	
	/*
	* easter egg methods for doing more with Core Graphics.
	*/
	/*
	* call this method after drawVolumeDataInRect: in the drawRect: method
	* and see what exciting drawing results.
	*/
	func drawBeachUnderDataInRect(_ rect: CGRect) {
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		let clipPath = self.bottomClipPathFromDataInRect(rect)
		clipPath.addClip()
		let image = UIImage(named: "Beach")
		image?.draw(in: rect)
	}
	
	/*
	* used to get the shadowed circles shown in the preso
	* not called as part of this sample, but here for your illumination
	*/
	func drawShadowedCirclesInRect(_ rect: CGRect) {
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		let shadowHeight: CGFloat = 16.0
		let radius: CGFloat = rect.height/2.5
		ctx?.setShadow(offset: CGSize(width: shadowHeight, height: shadowHeight), blur: 5.0, color: UIColor.purple.withAlphaComponent(0.7).cgColor)
		let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: 0.0, endAngle: 2.0*CGFloat.pi, clockwise: true)
		
		let color1: UIColor = UIColor(red: 99.0 / 255.0, green: 66.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
		let color2: UIColor = UIColor(red: 149.0 / 255.0, green: 64.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
		let color3: UIColor = UIColor(red: 195.0 / 255.0, green: 111.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)

		ctx?.beginTransparencyLayer(auxiliaryInfo: nil)
		color1.setFill()
		ctx?.translateBy(x: -radius/2.0, y: 0.0)
		path.fill()
		color2.setFill()
		ctx?.translateBy(x: 1.25*radius, y: 0.75 * radius)
		path.fill()
		color3.setFill()
		ctx?.translateBy(x: 0.0, y: -1.5 * radius)
		path.fill()
		ctx?.endTransparencyLayer()
		ctx?.restoreGState()
	}

}
