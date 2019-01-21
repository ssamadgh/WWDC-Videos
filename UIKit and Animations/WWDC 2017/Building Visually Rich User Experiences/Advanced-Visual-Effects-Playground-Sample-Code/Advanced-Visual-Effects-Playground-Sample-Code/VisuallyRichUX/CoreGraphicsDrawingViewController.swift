/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class demonstrates the fundamentals of drawing custom content with Core Graphics.
*/
import UIKit

class CoreGraphicsDrawingViewController: UIViewController {
    
    var imageView = UIImageView()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1480545461, green: 0.1480545461, blue: 0.1480545461, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Core Graphics"
        
        addSubviews()
    }
    
    func addSubviews() {
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        let views = [ "image": imageView ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[image]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]|", options: [], metrics: nil, views: views))
    }
    
    override func viewDidLayoutSubviews() {
        imageView.image = StarPolygonRenderer.image(withSize: view.bounds.size)
    }
}
