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
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurBackgroundView: UIVisualEffectView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleView: UITextView!
    
    var objectManager:ARObjectManager?
    var tourManager:ARTourManager?
    var locationManager:CLLocationManager?
    
    var session:ARSession?
    
    var initialARLocation:SCNVector3?
    var initialCLLocation:CLLocation?
    
    var initialized:Bool = false
    
    var showOverlay:Bool = false {
        didSet {
            if self.showOverlay == true {
                self.blurBackgroundView.isHidden = false
            } else {
                self.blurBackgroundView.isHidden = true
            }
        }
    }
    
    let arTap:UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.session = ARSession()
        
        self.sceneView.session = self.session!;
        self.sceneView.delegate = self;
        self.sceneView.antialiasingMode = SCNAntialiasingMode.multisampling4X
        self.sceneView.automaticallyUpdatesLighting = false;
        self.sceneView.preferredFramesPerSecond = 60;
        self.sceneView.autoenablesDefaultLighting = true;
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.locationManager = CLLocationManager()
        
        self.locationManager!.requestWhenInUseAuthorization()
        
        self.locationManager!.delegate = self
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager!.distanceFilter = 1 // meters
        self.locationManager!.startUpdatingLocation()
        self.locationManager!.startUpdatingHeading()
        
        self.initialCLLocation = nil
        self.initialARLocation = nil
        
        self.showOverlay = false
        
        arTap.addTarget(self, action: #selector(self.onTapGesture))
        self.view.addGestureRecognizer(arTap)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
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
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case ARCamera.TrackingState.normal:
            if self.initialized == false {
                let mat:SCNMatrix4 = SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform)
                self.initialARLocation = SCNVector3(mat.m41, mat.m42, mat.m43)
                
                self.objectManager = ARObjectManager(sceneView: self.sceneView, lMan: self.locationManager!)
                self.tourManager = ARTourManager(sceneView: self.sceneView,
                                                 objectManager: self.objectManager!,
                                                 lMan: self.locationManager!)
                self.objectManager!.addARItem(photoId: 0, file: "slide13.png", title: "Wine", description: "wine :)", lat: 37.447126, long: -122.18545, tours: [0], scale: 1)
                
                self.tourManager!.addARTour(tourID: 0, title: "blah", description: "blah", slat: 0, slong: 0, elat: 0, elong: 0, photos: [0], time: 10)
                
                self.tourManager!.startTour(tourID: 0)
                
                self.initialized = true
                return
            }
        default:
            return
        }
    }

    /*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }*/
    
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
        
        if self.showOverlay {
            self.showOverlay = false
            return
        }
        
        let tapLocation:CGPoint = tapGesture.location(in: self.sceneView)
        
        let options = [SCNHitTestOption.backFaceCulling: false]
        let hitResults = self.sceneView.hitTest(tapLocation, options: options)
        
        if(hitResults.count > 0) {
            let result = hitResults[0]
            if let m = objectManager {
                if let photo = m.getPhotoForNode(node: result.node) {
                    self.titleView.text = photo.title
                    self.textView.text = photo.description
                    self.showOverlay = true
                }
            }
        }
    }
    
    // callback for updating location from the location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.initialCLLocation == nil {
            self.initialCLLocation = locations.last!
        }
        
        guard let iAL = self.initialARLocation
            else { return }
        
        let clDistance:Float = Float(locations.last!.distance(from: self.initialCLLocation!))
        
        let mat:SCNMatrix4 = SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform)
        let arCurrPosition:SCNVector3 = SCNVector3(mat.m41, mat.m42, mat.m43)
        
        let arDistance:Float = SCNVector3Distance(vectorStart: iAL, vectorEnd: arCurrPosition)
        
        let distanceOff = abs(clDistance - arDistance)
        
        print("Distance off \(distanceOff)")
        
    }
}
