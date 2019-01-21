/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class illustrates the fundamentals of SceneKit, including how to load a 3D model, add it to a scene, and animate it with physics.
*/
import UIKit
import SceneKit
import SceneKit.ModelIO

class SceneKitViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var starGeometry: SCNGeometry!
    var starTimer: Timer!
    
    override func loadView() {
        sceneView = SCNView()
        view = sceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basic SceneKit"
        
        loadScene()
    }
    
    func loadScene() {
        scene = SCNScene()
        sceneView.scene = scene
        
        scene.background.contents = #imageLiteral(resourceName: "starfield")
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        let asset = MDLAsset(url: Bundle.main.url(forResource: "star", withExtension:"obj")!)
        if let mesh = asset[0] as? MDLMesh {
            starGeometry = SCNGeometry(mdlMesh: mesh)
        }
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        starGeometry.materials = [material]
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.position = SCNVector3(x: 10, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        startStarEmitter()
    }
    
    func startStarEmitter() {
        starTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let starNode = SCNNode(geometry: self.starGeometry)
            self.scene.rootNode.addChildNode(starNode)
            
            starNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: self.starGeometry, options: nil))
            starNode.physicsBody?.velocity = SCNVector3(5 * (drand48() - 0.5), 5 + 2 * drand48(), 5 * (drand48() - 0.5))
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                starNode.removeFromParentNode()
            }
        }
    }
}
