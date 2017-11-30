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
    @IBOutlet weak var photoInfoView: UIVisualEffectView!
    @IBOutlet weak var photoDescriptionBox: UITextView!
    @IBOutlet weak var photoTitleBox: UITextView!
    
    @IBOutlet weak var exploreModeTopButtonView: UIView!
    
    @IBOutlet weak var tourWindowView: UIVisualEffectView!
    
    @IBOutlet weak var startExploringButtonView: UIView!
    @IBOutlet weak var initializingARView: UIView!
    @IBOutlet weak var startScreenView: UIVisualEffectView!
    
    @IBOutlet weak var showMapButtonView: UIVisualEffectView!
    
    var objectManager:ARObjectManager?
    var tourManager:ARTourManager?
    var locationManager:CLLocationManager?
    
    var session:ARSession?
    
    var initialARLocation:SCNVector3?
    var initialCLLocation:CLLocation?
    var currCameraY:Float = 0 {
        didSet {
            if let tm = self.tourManager {
                tm.updateY(newY: self.currCameraY - 2.0)
            }
            
            if let om = self.objectManager {
                om.updateAllYs(newY: self.currCameraY - 2.0)
            }
        }
    }
    
    var arInitialized:Bool = false {
        didSet {
            if self.dataReady {
                self.initializingARView.isHidden = true
                self.startExploringButtonView.isHidden = false
            }
        }
    }
    
    var showPhotoInfo:Bool = false {
        didSet {
            if self.showPhotoInfo == true {
                self.photoInfoView.isHidden = false
                self.showMapButtonView.isHidden = true
            } else {
                self.photoInfoView.isHidden = true
                self.showMapButtonView.isHidden = false
            }
        }
    }
    
    var dataReady:Bool = false {
        didSet {
            self.objectManager = ARObjectManager(sceneView: self.sceneView, lMan: self.locationManager!)
            self.tourManager = ARTourManager(sceneView: self.sceneView,
                                             objectManager: self.objectManager!,
                                             lMan: self.locationManager!)
            
            AppData.importAllData(objectManager: self.objectManager!, tourManager: self.tourManager!)
            
            self.objectManager!.setAllVisible()
            self.tourManager!.startTour(tourID: 1)
            
            if self.arInitialized {
                self.initializingARView.isHidden = true
                self.startExploringButtonView.isHidden = false
            }
        }
    }
    
    var showTourSelections:Bool = false {
        didSet {
            if self.showTourSelections == true {
                self.showPhotoInfo = false
                self.exploreModeTopButtonView.isHidden = true
                self.tourWindowView.isHidden = false
                self.showMapButtonView.isHidden = true
            } else {
                self.exploreModeTopButtonView.isHidden = false
                self.tourWindowView.isHidden = true
                self.showMapButtonView.isHidden = false
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
        
        self.showPhotoInfo = false
        self.showTourSelections = false
        self.exploreModeTopButtonView.isHidden = true
        self.startExploringButtonView.isHidden = true
        self.showMapButtonView.isHidden = true
        
        arTap.addTarget(self, action: #selector(self.onTapGesture))
        self.view.addGestureRecognizer(arTap)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration,
                              options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
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
            if self.arInitialized == false {
                
                let mat:SCNMatrix4 = SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform)
                self.initialARLocation = SCNVector3(mat.m41, mat.m42, mat.m43)
                self.currCameraY = mat.m42
                self.arInitialized = true
                return
            }
            
        default:
            return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !self.arInitialized {
            return
        }
        
        let newY = SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform).m42
        if abs(newY - self.currCameraY) > 2 {
            self.currCameraY = newY
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
        
        if self.showPhotoInfo || self.showTourSelections {
            return
        }
        
        let tapLocation:CGPoint = tapGesture.location(in: self.sceneView)
        
        let options = [SCNHitTestOption.backFaceCulling: false]
        let hitResults = self.sceneView.hitTest(tapLocation, options: options)
        
        if(hitResults.count > 0) {
            let result = hitResults[0]
            if let m = objectManager {
                if let photo = m.getPhotoForNode(node: result.node) {
                    self.photoTitleBox.text = photo.title
                    self.photoDescriptionBox.text = photo.description
                    self.showPhotoInfo = true
                }
            }
        }
    }
    
    @IBAction func tourSelectionButton(_ sender: Any) {
        self.showTourSelections = true
    }
    
    @IBAction func closeTourInfoWindow(_ sender: Any) {
        self.showTourSelections = false
    }
    
    @IBAction func closePhotoInfoWindow(_ sender: Any) {
        self.showPhotoInfo = false
    }
    
    @IBAction func startExploringClicked(_ sender: Any) {
        self.startScreenView.isHidden = true
        self.showMapButtonView.isHidden = false
        self.exploreModeTopButtonView.isHidden = false
    }
    
    // MARK: - Location Callback
    
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
