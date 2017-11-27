//
//  ARTourManager.swift
//  CS147HiFi
//
//  Created by timaiken on 11/24/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import ARKit
import MapKit

class ARTourManager: NSObject {
    
    let arScene:ARSCNView
    let manager:ARObjectManager
    let locationManager:CLLocationManager
    
    var arTours:[Int: ARTour]
    var currTour:ARTour? = nil
    var currDirectionsNode:SCNNode = SCNNode()
    
    var currPhotoIndex:Int? = nil
    var currPID:Int? {
        get {
            if let c = self.currPhotoIndex, let ct = currTour {
                return ct.photos[c]
            }
            
            return nil
        }
    }
    
    init(sceneView: ARSCNView, objectManager:ARObjectManager, lMan:CLLocationManager) {
        
        self.arScene = sceneView
        self.manager = objectManager
        self.arTours = [:]
        self.locationManager = lMan
        self.arScene.scene.rootNode.addChildNode(self.currDirectionsNode)
        
    }
    
    // https://stackoverflow.com/questions/45185555/swift-scenekit-get-direction-of-camera
    func getARLocation() -> SCNVector3 {
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
    
    
    func addARTour(tourID:Int, title:String, description:String, photos:[Int], time:TimeInterval) {
        
        let newTour:ARTour = ARTour(tID: tourID,
                                    t: title,
                                    d: description,
                                    ps: photos,
                                    time: time)
        
        self.arTours[tourID] = newTour
        
        // https://stackoverflow.com/questions/21861403/latitude-and-longitude-points-from-mkpolyline
        
    }
    
    func startTour(tourID:Int) {
        guard let _ = self.arTours[tourID]
            else { return }
        
        self.currTour = self.arTours[tourID]
        self.currPhotoIndex = 0
        
        for pID in self.arTours[tourID]!.photos {
            self.manager.setPhotoVisible(pID: pID)
        }
        
        displayDirectionsToCurrPhoto()
    }
    
    func advanceTour() -> Bool {
        if self.currPhotoIndex != nil && self.currPhotoIndex! < self.currTour!.photos.count {
            self.currPhotoIndex! += 1
            displayDirectionsToCurrPhoto()
            return true
        }
        
        return false
    }
    
    func endTour(tourID:Int) {
        
        for childNode in self.currDirectionsNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        self.currPhotoIndex = nil
        self.currTour = nil
        self.manager.setAllVisible()
    }
    
    func displayDirectionsToCurrPhoto() {
        guard let currLoc:CLLocation = locationManager.location, let pid = self.currPID
            else { return }
        
        let start:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currLoc.coordinate))
        let endCoor = self.manager.arPhotos[pid]!.location.coordinate
        let end:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: endCoor))
        
        let request:MKDirectionsRequest = MKDirectionsRequest()
        request.source = start
        request.destination = end
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if let r = response?.routes[0] {
                self.drawRoute(route: r)
            }
        }
        
    }
    
    func drawRoute(route:MKRoute) {
        
        let pointCount = route.polyline.pointCount
        var points = [CLLocationCoordinate2D](repeating:CLLocationCoordinate2D(), count:pointCount)
        route.polyline.getCoordinates(&points, range: NSMakeRange(0, pointCount))
        
        for childNode in self.currDirectionsNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        var prevCoor:CLLocation? = nil
        for coor in points {
        
            let currCoor = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
            drawNodeOnRoute(loc: currCoor)
            
            if let p = prevCoor {
                let dist = p.distance(from: currCoor)
                let divide = Int(ceil(dist / 2.0))
                let deltaLat = (currCoor.coordinate.latitude - p.coordinate.latitude) / Double(divide)
                let deltaLong = (currCoor.coordinate.longitude - p.coordinate.longitude) / Double(divide)
                
                for i in 1..<divide {
                    let partialCoor = CLLocation(latitude: p.coordinate.latitude + deltaLat * Double(i),
                                                 longitude: p.coordinate.longitude + deltaLong * Double(i))
                    
                    drawNodeOnRoute(loc: partialCoor)
                }
            }
            
            prevCoor = currCoor
        }
    }

    func drawNodeOnRoute(loc:CLLocation) {
        guard let currLoc:CLLocation = locationManager.location
            else{ return}
        
        let sphere:SCNSphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial!.diffuse.contents = UIColor.red
        
        let newNode = SCNNode(geometry: sphere)
        let nodeLoc = ARObjectManager.getARPosition(currLocCLL: currLoc, currLocAR: self.getARLocation(), objectLocCLL: loc)
        newNode.position = nodeLoc
        self.currDirectionsNode.addChildNode(newNode)
    }
    
    
    
}
