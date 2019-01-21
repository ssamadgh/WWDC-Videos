/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is a utility class that uses UIGraphicsImageRenderer and Core Graphics to draw star-shaped regular polygon images.
*/

import UIKit

class StarPolygonRenderer {
    class func image(withSize size: CGSize, fillColor: UIColor = UIColor.yellow, pointCount: Int = 5, radiusRatio: CGFloat = 0.382) -> UIImage {
        let outerRadius = min(size.width, size.height) / 2
        let innerRadius = outerRadius * radiusRatio
        
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { rendererContext in
            let cgContext = rendererContext.cgContext
            cgContext.setFillColor(fillColor.cgColor)
            
            let angleStride = (2 * CGFloat.pi) / CGFloat(pointCount)
            
            var outerAngle = CGFloat.pi / 2
            var innerAngle = outerAngle - (angleStride / 2)
            
            let topPoint = CGPoint(x: centerX + outerRadius * cos(outerAngle),
                                   y: centerY - outerRadius * sin(outerAngle))
            cgContext.move(to: topPoint)
            
            for _ in 0..<pointCount {
                outerAngle += angleStride
                innerAngle += angleStride
                
                let innerPoint = CGPoint(x: centerX + innerRadius * cos(innerAngle),
                                         y: centerY - innerRadius * sin(innerAngle))
                cgContext.addLine(to: innerPoint)
                
                let outerPoint = CGPoint(x: centerX + outerRadius * cos(outerAngle),
                                         y: centerY - outerRadius * sin(outerAngle))
                cgContext.addLine(to: outerPoint)
            }
            
            cgContext.fillPath()
        }
        
        return image
    }
}

