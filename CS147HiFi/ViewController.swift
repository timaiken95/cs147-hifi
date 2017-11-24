//
//  ViewController.swift
//  CS147HiFi
//
//  Created by timaiken on 11/21/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var manager:ARObjectManager?
    
    let arTap:UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.manager = ARObjectManager(sceneView: sceneView)
        arTap.addTarget(self.manager!, action: #selector(self.onTapGesture))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Gesture Recognizers
    
    @objc func onTapGesture(tapGesture: UITapGestureRecognizer) {
        let tapLocation:CGPoint = tapGesture.location(in: self.sceneView)
        
        let options = [SCNHitTestOption.backFaceCulling: false]
        let hitResults = self.sceneView.hitTest(tapLocation, options: options)
        
        if(hitResults.count > 0) {
            let result = hitResults[0]
            if let m = manager {
                if photo = m.getPhotoForNode(node: result.node) {
                    
                }
            }
        }
    }
}
