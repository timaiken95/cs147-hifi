//
//  ARObjectManager.swift
//  CS147HiFi
//
//  Created by clmeiste on 11/21/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import CoreLocation
import ARKit

class ARObjectManager: NSObject, CLLocationManagerDelegate {
    
    let arScene:ARSCNView
    let locationManager:CLLocationManager
    
    let initialARLocation:SCNVector3
    let initialARHeading:Float
    
    var initialCLLocation:CLLocation
    var initialCLHeading:CLHeading
    
    init(sceneView: ARSCNView) {
        
        self.arScene = sceneView
        
        self.locationManager = CLLocationManager()
        
        // https://stackoverflow.com/questions/45185555/swift-scenekit-get-direction-of-camera
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        self.initialARLocation = SCNVector3(mat.m41, mat.m42, mat.m43)
        self.initialARHeading = self.arScene.session.currentFrame!.camera.eulerAngles.y
        
        self.initialCLHeading = CLHeading()
        self.initialCLLocation = CLLocation()
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 20 // meters
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        self.initialCLLocation = locationManager.location!
        self.initialCLHeading = locationManager.heading!
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let clRotation:Float = Float(newHeading.trueHeading - initialCLHeading.trueHeading)
        let arRotation:Float = self.arScene.session.currentFrame!.camera.eulerAngles.y - self.initialARHeading
        
        let rotationOff = abs(clRotation - arRotation)
        
        print("Heading off \(rotationOff)")
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let clDistance:Float = Float(locations.last!.distance(from: initialCLLocation))
        
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        let arCurrPosition:SCNVector3 = SCNVector3(mat.m41, mat.m42, mat.m43)
        
        let arDistance:Float = SCNVector3Distance(vectorStart: self.initialARLocation, vectorEnd: arCurrPosition)
        
        let distanceOff = abs(clDistance - arDistance)
        
        print("Distance off \(distanceOff)")
        
    }
    
}
