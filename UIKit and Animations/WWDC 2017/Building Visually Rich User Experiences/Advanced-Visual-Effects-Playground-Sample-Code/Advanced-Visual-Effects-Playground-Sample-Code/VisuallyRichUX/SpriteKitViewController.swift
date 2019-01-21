/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class demonstrates how to load a set of SpriteKit emitter node properties and display the emitter in a scene.
*/
import UIKit
import SpriteKit

class SpriteKitViewController: UIViewController {
    
    var sceneView: SKView!
    var scene: SKScene!
    var emitter: SKEmitterNode!
    
    override func loadView() {
        sceneView = SKView()
        view = sceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basic SpriteKit"
        
        loadScene()
    }
    
    func loadScene() {
        scene = SKScene(size: UIScreen.main.bounds.size)
        sceneView.presentScene(scene)
        
        emitter = SKEmitterNode(fileNamed: "star-particle-effect.sks")
        
        let starImage = StarPolygonRenderer.image(withSize: CGSize(width: 64, height: 64))
        emitter.particleTexture = SKTexture(image: starImage)
        emitter.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        sceneView.scene?.addChild(emitter)
    }
}

