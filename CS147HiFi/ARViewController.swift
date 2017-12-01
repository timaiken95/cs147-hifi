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

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var photoInfoView: UIVisualEffectView!
    @IBOutlet weak var photoDescriptionBox: UITextView!
    @IBOutlet weak var photoTitleBox: UITextView!
    @IBOutlet weak var photoImageBox: UIImageView!
    
    @IBOutlet weak var exploreModeTopButtonView: UIView!
    @IBOutlet weak var tourModeTopButtonView: UIView!
    
    @IBOutlet weak var tourTable: UITableView!
    @IBOutlet weak var tourWindowView: UIVisualEffectView!
    
    @IBOutlet weak var infoButtonView: UIView!
    @IBOutlet weak var startExploringButtonView: UIView!
    @IBOutlet weak var initializingARView: UIView!
    @IBOutlet weak var startScreenView: UIVisualEffectView!
    
    @IBOutlet weak var tourInfoWindow: UIVisualEffectView!
    @IBOutlet weak var tourInfoWindowDistanceField: UILabel!
    @IBOutlet weak var tourInfoWindowTimeField: UILabel!
    @IBOutlet weak var tourInfoWindowNameField: UILabel!
    @IBOutlet weak var tourInfoWindowDescriptionField: UITextView!
    
    @IBOutlet weak var doneWithTourButton: UIView!
    @IBOutlet weak var cancelTourView: UIVisualEffectView!
    
    @IBOutlet weak var tourDistanceLeftLabel: UILabel!
    @IBOutlet weak var tourStoriesFoundLabel: UILabel!
    
    @IBOutlet weak var showMapButtonView: UIVisualEffectView!
    
    @IBOutlet weak var infoScreenView: UIVisualEffectView!
    
    @IBOutlet weak var infoScreenTitle1: UILabel!
    @IBOutlet weak var infoScreenTitle2: UILabel!
    @IBOutlet weak var infoScreenDescription1: UILabel!
    @IBOutlet weak var infoScreenDescription2: UILabel!
    
    var objectManager:ARObjectManager?
    var tourManager:ARTourManager?
    var locationManager:CLLocationManager?
    
    var session:ARSession?
    
    var tour:ARTour?
    
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
                                             lMan: self.locationManager!,
                                             distLeft: self.tourDistanceLeftLabel,
                                             storiesFound: self.tourStoriesFoundLabel
            )
            
            AppData.importAllData(objectManager: self.objectManager!, tourManager: self.tourManager!)
            
            self.tourTable.reloadData()
            
            self.objectManager!.setAllVisible()
            self.objectManager!.updateAllYs(newY: SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform).m42 - 2.0)
            
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
                self.infoButtonView.isHidden = true
                self.tourWindowView.isHidden = false
                self.showMapButtonView.isHidden = true
            } else {
                self.exploreModeTopButtonView.isHidden = false
                self.infoButtonView.isHidden = false
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
        self.infoButtonView.isHidden = true
        self.exploreModeTopButtonView.isHidden = true
        self.tourModeTopButtonView.isHidden = true
        self.startExploringButtonView.isHidden = true
        self.showMapButtonView.isHidden = true
        self.tourInfoWindow.isHidden = true
        self.cancelTourView.isHidden = true
        self.infoScreenView.isHidden = true
        
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
    
    var previousTime:TimeInterval = 0
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if time - self.previousTime < 5 {
            return
        }
        self.previousTime = time
        
        if !self.arInitialized {
            return
        }
        let mat:SCNMatrix4 = SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform)
        
        let newY = mat.m42
        if abs(newY - self.currCameraY) > 1 {
            self.currCameraY = newY
        }
        
        guard let tm = self.tourManager, let _ = tm.currTour else { return }
        
        let currLocation:SCNVector3 = SCNVector3(mat.m41, mat.m42, mat.m43)
        tm.checkIfAdvance(loc: currLocation)
        
        if tm.finished {
            self.doneWithTourButton.isHidden = false
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
                    self.photoImageBox.image = photo.imageFile
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
        self.infoButtonView.isHidden = false
    }
    
    @IBAction func exitTourInfoWindow(_ sender: Any) {
        self.tourInfoWindow.isHidden = true
        self.tour = nil
    }
    
    @IBAction func startTourButtonClicked(_ sender: Any) {
        self.tourManager!.startTour(tourID: self.tour!.tourID)
        self.tourManager!.updateY(newY: SCNMatrix4(self.sceneView.session.currentFrame!.camera.transform).m42 - 2.0)
        self.showTourSelections = false
        self.tourInfoWindow.isHidden = true
        self.exploreModeTopButtonView.isHidden = true
        self.tourModeTopButtonView.isHidden = false
        self.doneWithTourButton.isHidden = true
        self.showMapButtonView.isHidden = true
        
    }
    @IBAction func doneWithTourButtonClicked(_ sender: Any) {
        self.tourManager!.endTour()
        self.tourModeTopButtonView.isHidden = true
        self.showMapButtonView.isHidden = false
        self.exploreModeTopButtonView.isHidden = false
    }
    
    @IBAction func cancelTourButtonClicked(_ sender: Any) {
        self.cancelTourView.isHidden = false
    }
    @IBAction func undoCancelTour(_ sender: Any) {
        self.cancelTourView.isHidden = true
    }
    
    @IBAction func confirmCancelTour(_ sender: Any) {
        self.tourManager!.endTour()
        self.cancelTourView.isHidden = true
        self.tourModeTopButtonView.isHidden = true
        self.showMapButtonView.isHidden = false
        self.exploreModeTopButtonView.isHidden = false
    }
    
    @IBAction func closeInfoScreen(_ sender: Any) {
        self.infoScreenView.isHidden = true
    }
    
    @IBAction func didClickInfoButton(_ sender: Any) {
        if let _ = self.tourManager?.currTour {
            self.infoScreenTitle1.text = "Tour-Mode"
            self.infoScreenTitle2.text = "Tour-Mode"
            self.infoScreenDescription1.text = "Follow the arrows to discover different stories."
            self.infoScreenDescription2.text = "You can cancel at any time if you don't feel like continuing the tour. Just press the cancel button."
        } else {
            self.infoScreenTitle1.text = "Explore-Mode"
            self.infoScreenTitle2.text = "Explore-Mode"
            self.infoScreenDescription1.text = "You can move your phone and look for images floating in the air."
            self.infoScreenDescription2.text = "If you don't see any images or arrows, check out the map to see where to find something!"
        }
        self.infoScreenView.isHidden = false
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
    
    // MARK: Table Callback
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let t = self.tourManager {
            return t.arTours.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tourCell") as! TourTableCell
        if let t = self.tourManager {
            let tour = t.arTours[indexPath.section + 1]!
            cell.tourDuration.text = String(Int(tour.estimatedTime))
            cell.tourName.text = tour.title
            cell.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let t = self.tourManager
            else { return }
        self.tour = t.arTours[indexPath.section + 1]!
        
        self.tourInfoWindowNameField.text = self.tour!.title
        self.tourInfoWindowDescriptionField.text = self.tour!.description
        
        let firstPhotoLocation = self.objectManager!.arPhotos[self.tour!.photos[0]]!.location
        let distanceToFirstPhoto = locationManager!.location!.distance(from: firstPhotoLocation) * 3.3 / 5280.0
        let totalTime = self.tour!.estimatedTime + distanceToFirstPhoto * 30
        
        self.tourInfoWindowTimeField.text = "Total time: " + String(Int(totalTime)) + " min"
        self.tourInfoWindowDistanceField.text = "Distance to first photo: " + String(format: "%.1f", distanceToFirstPhoto) + " mi"
        self.tourInfoWindow.isHidden = false
        
    }
    
}
