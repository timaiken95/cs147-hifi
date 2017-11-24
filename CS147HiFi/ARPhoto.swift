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
    var visible:Bool
    
    init(pID:Int, filename:String, t: String, d: String, lat: Float, long: Float, ts:[Int], s:Float) {
        self.photoID = pID
        self.imageFile = UIImage(named: filename)!
        self.title = t
        self.description = d
        self.location = CLLocation(latitude: Double(lat), longitude: Double(long))
        self.tours = ts
        self.visible = false
        self.geometryNode = SCNNode()
        self.scale = s
        
        createGeometry()
    }
    
    func createGeometry() {
        let width:CGFloat = imageFile.size.width * CGFloat(self.scale * 10.0) / (imageFile.size.width + imageFile.size.height)
        let height:CGFloat = imageFile.size.height * CGFloat(self.scale * 10.0) / (imageFile.size.width + imageFile.size.height)
        
        let plane:SCNPlane = SCNPlane(width: width, height: height)
        plane.cornerRadius = CGFloat(self.scale)
        
        plane.firstMaterial!.diffuse.contents = self.imageFile
        
        self.geometryNode.geometry = plane
        self.geometryNode.constraints = [SCNBillboardConstraint()]
    }
    
    // https://developer.apple.com/documentation/arkit/arconfiguration.worldalignment/2873776-gravityandheading
    func updatePosition(currLocCLL:CLLocation, currLocAR:SCNVector3) {
        
        let distance:Double = location.distance(from: currLocCLL)
        var photoHeadingZ:Double =  self.location.coordinate.latitude - currLocCLL.coordinate.latitude
        var photoHeadingX:Double = self.location.coordinate.longitude - currLocCLL.coordinate.longitude
        
        let magnitude:Double = sqrt(pow(photoHeadingZ, 2.0) + pow(photoHeadingX, 2.0))
        photoHeadingZ *= distance / magnitude
        photoHeadingX *= distance / magnitude
        
        let position:SCNVector3 = SCNVector3Make(currLocAR.x + Float(photoHeadingX),
                                                 0,
                                                 currLocAR.z + Float(photoHeadingZ))
        self.geometryNode.position = position
        
    }
    
}
