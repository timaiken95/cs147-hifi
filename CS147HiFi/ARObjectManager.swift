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

class ARObjectManager {
    
    let arScene:ARSCNView
    let locationManager:CLLocationManager
    
    var arPhotos:[Int:ARPhoto]
    
    init(sceneView: ARSCNView, lMan:CLLocationManager) {
        
        self.arScene = sceneView
        self.locationManager = lMan
        
        self.arPhotos = [:]
    }
    
    // https://stackoverflow.com/questions/45185555/swift-scenekit-get-direction-of-camera
    func getARLocation() -> SCNVector3 {
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
    
    func addARItem(newPhoto:ARPhoto) {
        self.arScene.scene.rootNode.addChildNode(newPhoto.geometryNode)
        newPhoto.updatePosition(currLocCLL: locationManager.location!, currLocAR: getARLocation())
        self.arPhotos[newPhoto.photoID] = newPhoto
    }
    
    func getPhotoForNode(node:SCNNode) -> ARPhoto? {
        for pID in arPhotos.keys {
            if(arPhotos[pID]!.geometryNode == node) {
                return arPhotos[pID]!
            }
        }
        
        return nil
    }
    
    func setAllVisible() {
        for pID in arPhotos.keys {
            arPhotos[pID]!.visible = true
        }
    }
    
    func setPhotoVisible(pID:Int) {
        arPhotos[pID]!.visible = true
    }
    
    func setPhotoInvisible(pID:Int) {
        arPhotos[pID]!.visible = false
    }
    
    func updateAllYs(newY:Float) {
        for photo in self.arPhotos.values {
            photo.updateY(newY: newY)
        }
    }
    
     // https://developer.apple.com/documentation/arkit/arconfiguration.worldalignment/2873776-gravityandheading
    class func getARPosition(currLocCLL:CLLocation, currLocAR:SCNVector3, objectLocCLL:CLLocation) -> SCNVector3 {
        
        let distance:Double = objectLocCLL.distance(from: currLocCLL)
        var photoHeadingZ:Double =  -objectLocCLL.coordinate.latitude + currLocCLL.coordinate.latitude
        var photoHeadingX:Double = objectLocCLL.coordinate.longitude - currLocCLL.coordinate.longitude
        
        let magnitude:Double = sqrt(pow(photoHeadingZ, 2.0) + pow(photoHeadingX, 2.0))
        photoHeadingZ *= distance / magnitude
        photoHeadingX *= distance / magnitude
        
        let position:SCNVector3 = SCNVector3Make(currLocAR.x + Float(photoHeadingX),
                                                 0,
                                                 currLocAR.z + Float(photoHeadingZ))
        
        return position
    }
    
}


