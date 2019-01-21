/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller that supports pasting and installs drag and drop interactions on its view.
             It also provides helper functions used by paste and drop operations to load and display images in the pin board.
*/
import UIKit

class DragBoardViewController: UIViewController {

    var images = [UIImage]()
    var views  = [UIView]()
    
    /// A property that keeps track of the location where the drop operation was performed.
    var dropPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasteMenu()
        
        // Set a paste configuration
        pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        
        // Add drag interaction
        view.addInteraction(UIDragInteraction(delegate: self))
        
        // Add drop interaction
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    // MARK: - Paste
    
    override func paste(itemProviders: [NSItemProvider]) {
        for item in itemProviders {
            loadImage(item, center: dropPoint)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Asynchronously loads an image from the given item provider and
    /// displays it it in the image view.
    ///
    /// - Parameters:
    ///   - itemProvider: an item provider that can load an image.
    ///   - imageView: the image view that will display the loaded image.
    func loadImage(_ itemProvider: NSItemProvider, center: CGPoint) {
        itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
            DispatchQueue.main.async {
                let image = object as! UIImage
                let imageView = self.newImageView(image: image)
                imageView.center = center
                
                self.images.append(image)
            }
        }
    }
    
    /// Creates a new image view with the given image and
    /// scales it down if it exceeds a maximum size.
    ///
    /// - Parameter image: the image to be displayed in the image view.
    /// - Returns: A newly created image view with the given image, resized if necessary.
    func newImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = image
        
        var size = image.size
        let longestSide = max(size.width, size.height)
        let maximumLength: CGFloat = 200
        var scaleFactor: CGFloat = 1
        
        // If the given image exceeds `maximumLength`,
        // we resize the image view to match that length
        // while preserving the original aspect ratio.
        if longestSide > maximumLength {
            scaleFactor = maximumLength / longestSide
        }
        size = CGSize(width: round(size.width * scaleFactor), height: round(size.height * scaleFactor))
        imageView.frame.size = size
        
        views.append(imageView)
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }
    
    /// Changes the alpha value of drag items already
    /// inserted in the pin board.
    ///
    /// - Parameters:
    ///   - items: the list of drag items.
    ///   - alpha: the alpha value applied to each drag item.
    func fade(items: [UIDragItem], alpha: CGFloat) {
        for item in items {
            if let index = item.localObject as? Int {
                views[index].alpha = alpha
            }
        }
    }

}
