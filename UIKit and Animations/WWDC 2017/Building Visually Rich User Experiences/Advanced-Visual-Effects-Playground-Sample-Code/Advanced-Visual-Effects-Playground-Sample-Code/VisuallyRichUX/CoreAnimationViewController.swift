/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class demonstrates how to create and animate instances of CALayer to create engaging interactions.
*/
import UIKit

class CoreAnimationViewController: UIViewController {
    
    let starCount = 28
    let initialRadius = CGFloat(25)
    let finalRadius = CGFloat(150)
    let initialSize = CGFloat(32)
    let animationDuration = 1.25
    let finalScale = CGFloat(0.1)
    let spinRadians = 4 * CGFloat.pi
    let starColors = [ #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0.4003627232, green: 1, blue: 0.3994977679, alpha: 1), #colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.5, green: 0, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0.5, alpha: 1) ]
    
    var starImages = [UIImage]()
    
    var button = UIButton()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1480545461, green: 0.1480545461, blue: 0.1480545461, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Core Animation"
        
        generateImages()
        
        addSubviews()
    }
    
    func generateImages() {
        starImages = starColors.map { color in
            StarPolygonRenderer.image(withSize: CGSize(width: 128, height: 128), fillColor: color)
        }
    }
    
    func addSubviews() {
        view.addSubview(button)
        
        let attributedTitle = NSAttributedString(string: "Push Me!", attributes: [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 28),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.addTarget(self, action: #selector(buttonWasPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal,
                                              toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal,
                                              toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    @objc
    func buttonWasPressed(_ sender: Any?) {
        playStarAnimation()
    }
    
    func playStarAnimation() {
        let center = CGPoint(x: button.layer.bounds.midX, y: button.layer.bounds.midY)
        
        for i in 0..<starCount {
            let layer = CALayer()
            layer.contents = starImages[i % starImages.count].cgImage
            let angle = CGFloat(i) * (2 * CGFloat.pi / CGFloat(starCount - 1))
            let initialPosition = CGPoint(x: center.x + initialRadius * cos(angle), y: center.y + initialRadius * -sin(angle))
            layer.position = initialPosition
            layer.bounds = CGRect(x: 0, y: 0, width: initialSize, height: initialSize)
            
            button.layer.addSublayer(layer)
            
            let finalPosition = CGPoint(x: center.x + finalRadius * cos(angle), y: center.y + finalRadius * -sin(angle))
            
            var finalTransform = CATransform3DMakeTranslation(finalPosition.x - initialPosition.x, finalPosition.y - initialPosition.y, 0)
            finalTransform = CATransform3DRotate(finalTransform, spinRadians, 0, 0, 1)
            finalTransform = CATransform3DScale(finalTransform, finalScale, finalScale, finalScale)
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = layer.transform
            animation.toValue = finalTransform
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            layer.add(animation, forKey: "pew pew")
            
            layer.transform = finalTransform
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationDuration, execute: {
                layer.removeFromSuperlayer()
            })
        }
    }
}
