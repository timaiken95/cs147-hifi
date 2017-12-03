//
//  ARPhoto.swift
//  CS147HiFi
//
//  Created by timaiken on 11/22/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

class ARPhoto {
    let photoID: Int
    let imageFile: UIImage
    let title: String
    let description: String
    let location: CLLocation
    let tours: [Int]
    let scale:Float
    let geometryNode:SCNNode
    
    var visible:Bool {
        set {
            if newValue == true {
                self.geometryNode.isHidden = false
            } else {
                self.geometryNode.isHidden = true
            }
        }
        
        get {
            return self.visible
        }
    }
    
    init(pID:Int, filename:String, t: String, d: String, lat: Float, long: Float, ts:[Int], s:Float) {
        self.photoID = pID
        self.imageFile = UIImage(named: filename)!
        self.title = t
        self.description = d
        self.location = CLLocation(latitude: Double(lat), longitude: Double(long))
        self.tours = ts
        self.geometryNode = SCNNode()
        self.scale = s
        
        UserDefaults.standard.set(false, forKey: "seen" + String(pID))
        
        // set this last
        self.visible = true
        
        createGeometry()
    }
    
    func createGeometry() {
        let width:CGFloat = imageFile.size.width * CGFloat(self.scale * 10.0) / (imageFile.size.width + imageFile.size.height)
        let height:CGFloat = imageFile.size.height * CGFloat(self.scale * 10.0) / (imageFile.size.width + imageFile.size.height)
        
        let plane:SCNPlane = SCNPlane(width: width, height: height)
        plane.cornerRadius = CGFloat(self.scale)
        
        plane.firstMaterial!.diffuse.contents = self.imageFile
        
        self.geometryNode.geometry = plane
        
        let billboard = SCNBillboardConstraint()
        billboard.freeAxes = SCNBillboardAxis.Y
        
        self.geometryNode.constraints = [billboard]
        
    }
    
    func updatePosition(currLocCLL:CLLocation, currLocAR:SCNVector3) {
        let loc = ARObjectManager.getARPosition(currLocCLL: currLocCLL, currLocAR: currLocAR, objectLocCLL: self.location)
        self.geometryNode.position = loc
    }
    
    func updateY(newY:Float) {
        self.geometryNode.position = SCNVector3Make(self.geometryNode.position.x,
                                                    newY,
                                                    self.geometryNode.position.z)
    }
    
}
