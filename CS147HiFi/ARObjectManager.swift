//
//  ARObjectManager.swift
//  CS147HiFi
//
//  Created by timaiken on 11/21/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import ARKit
import MapKit

class ARObjectManager: NSObject, CLLocationManagerDelegate {
    
    let arScene:ARSCNView
    let locationManager:CLLocationManager
    
    var initialARLocation:SCNVector3
    var initialARHeading:Float
    
    var initialCLLocation:CLLocation
    var initialCLHeading:CLHeading
    
    var arPhotos:[ARPhoto]
    
    init(sceneView: ARSCNView) {
        
        self.arScene = sceneView
        
        self.locationManager = CLLocationManager()
        
        self.initialARLocation = SCNVector3Zero
        self.initialARHeading = 0
        self.initialCLHeading = CLHeading()
        self.initialCLLocation = CLLocation()
        
        self.arPhotos = []
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 20 // meters
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        self.initialCLLocation = locationManager.location!
        self.initialCLHeading = locationManager.heading!
        self.initialARLocation = getARLocation()
        self.initialARHeading = self.arScene.session.currentFrame!.camera.eulerAngles.y
        
        
    }
    
    // callback for updating heading from the location manager
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let clRotation:Float = Float(newHeading.trueHeading - initialCLHeading.trueHeading)
        let arRotation:Float = self.arScene.session.currentFrame!.camera.eulerAngles.y - self.initialARHeading
        
        let rotationOff = abs(clRotation - arRotation)
        
        print("Heading off \(rotationOff)")
        
        
    }
    
    // callback for updating location from the location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let clDistance:Float = Float(locations.last!.distance(from: initialCLLocation))
        
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        let arCurrPosition:SCNVector3 = SCNVector3(mat.m41, mat.m42, mat.m43)
        
        let arDistance:Float = SCNVector3Distance(vectorStart: self.initialARLocation, vectorEnd: arCurrPosition)
        
        let distanceOff = abs(clDistance - arDistance)
        
        print("Distance off \(distanceOff)")
        
    }
    
    // https://stackoverflow.com/questions/45185555/swift-scenekit-get-direction-of-camera
    func getARLocation() -> SCNVector3 {
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
    
    func addARItem(photoId:Int, file:String, title:String, description:String, lat:Float, long:Float, tours:[Int], scale:Float) {
        let newPhoto:ARPhoto = ARPhoto(pID: photoId,
                                       filename: file,
                                       t: title,
                                       d: description,
                                       lat: lat,
                                       long: long,
                                       ts: tours,
                                       s: scale)
        
        newPhoto.updatePosition(currLocCLL: locationManager.location!, currLocAR: getARLocation())
        self.arPhotos.append(newPhoto)
        
        // https://stackoverflow.com/questions/21861403/latitude-and-longitude-points-from-mkpolyline
        
    }
    
    func getPhotoForNode(node:SCNNode) -> ARPhoto? {
        for photo in arPhotos {
            if(photo.geometryNode == result.node) {
                return photo
            }
        }
        
        return nil
    }
    
}
