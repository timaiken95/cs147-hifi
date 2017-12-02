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
    
    let storiesFoundLabel:UILabel
    let distanceLeftLabel:UILabel
    
    var finished = false
    
    var currPhotoIndex:Int? = nil
    var currPID:Int? {
        get {
            if let c = self.currPhotoIndex, let ct = currTour {
                return ct.photos[c]
            }
            
            return nil
        }
    }
    
    init(sceneView: ARSCNView, objectManager:ARObjectManager, lMan:CLLocationManager, distLeft:UILabel, storiesFound:UILabel) {
        
        self.arScene = sceneView
        self.manager = objectManager
        self.arTours = [:]
        self.locationManager = lMan
        self.arScene.scene.rootNode.addChildNode(self.currDirectionsNode)
        
        self.distanceLeftLabel = distLeft
        self.storiesFoundLabel = storiesFound
        
    }
    
    // https://stackoverflow.com/questions/45185555/swift-scenekit-get-direction-of-camera
    func getARLocation() -> SCNVector3 {
        let mat:SCNMatrix4 = SCNMatrix4(self.arScene.session.currentFrame!.camera.transform)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
    
    
    func addARTour(newTour:ARTour) {
        self.arTours[newTour.tourID] = newTour
        
        // https://stackoverflow.com/questions/21861403/latitude-and-longitude-points-from-mkpolyline
    }
    
    func startTour(tourID:Int) {
        guard let _ = self.arTours[tourID]
            else { return }
        
        self.distanceLeftLabel.text = "-- mi"
        
        self.currTour = self.arTours[tourID]
        self.currPhotoIndex = 0
        
        for pID in self.manager.arPhotos.keys {
            if pID == self.currPID! {
                self.manager.setPhotoVisible(pID: pID)
            } else {
                self.manager.setPhotoInvisible(pID: pID)
            }
        }
        
        displayDirectionsToCurrPhoto()
        displayPhotosFound()
        displayDistanceLeftInTour()
    }
    
    var prevLoc = SCNVector3Zero
    func checkIfAdvance(loc:SCNVector3) {
        guard let pid = self.currPID else { return }
        
        if SCNVector3Distance(vectorStart: prevLoc, vectorEnd: loc) < 5 {
            return
        }
        prevLoc = loc
        
        let photo:ARPhoto = self.manager.arPhotos[pid]!
        let dist = SCNVector3Distance(vectorStart: photo.geometryNode.position, vectorEnd: loc)
        print(dist)
        
        if dist < 10 {
            if !self.advanceTour() {
                self.finished = true
                for childNode in self.currDirectionsNode.childNodes {
                    childNode.removeFromParentNode()
                }
            }
            
            displayPhotosFound()
            
        }
        
        displayDistanceLeftInTour()
        
    }
    
    func advanceTour() -> Bool {
        print("Advancing to next step in tour")
        if self.currPhotoIndex != nil && self.currPhotoIndex! < self.currTour!.photos.count - 1 {
            self.currPhotoIndex! += 1
            self.manager.setPhotoVisible(pID: self.currPID!)
            displayDirectionsToCurrPhoto()
            return true
        }
        
        return false
    }
    
    func endTour() {
        
        for childNode in self.currDirectionsNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        self.currPhotoIndex = nil
        self.finished = false
        self.currTour = nil
        self.manager.setAllVisible()
    }
    
    func displayDistanceLeftInTour() {
        
        print("Updating distance for tour")
        
        guard let cidx = currPhotoIndex, let currLoc:CLLocation = locationManager.location, let t = currTour
            else { return }
        
        DispatchQueue.global(qos: .background).async {
            let semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
            var mutex:pthread_mutex_t = pthread_mutex_t()
            let numToWait:Int = t.photos.count - cidx
            
            var locs:[CLLocationCoordinate2D] = []
            for i in cidx..<t.photos.count {
                locs.append(self.manager.arPhotos[t.photos[i]]!.location.coordinate)
            }
            
            var dist:Double = 0
            
            var prevCoor:CLLocationCoordinate2D = currLoc.coordinate
            for coor in locs {
                let start:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: prevCoor))
                let end:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: coor))
                
                let request:MKDirectionsRequest = MKDirectionsRequest()
                request.source = start
                request.destination = end
                request.requestsAlternateRoutes = false
                request.transportType = .walking
                
                let directions = MKDirections(request: request)
                directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
                    if let r = response?.routes[0] {
                        pthread_mutex_lock(&mutex)
                        dist += r.distance * 3.3 / 5280
                        pthread_mutex_unlock(&mutex)
                    }
                    semaphore.signal()
                }
                
                prevCoor = coor
            }
            
            for _ in 0..<numToWait {
                semaphore.wait()
            }
            
            DispatchQueue.main.async {
                self.distanceLeftLabel.text = String(format: "%.1f", Float(dist)) + " mi"
            }
        }
            
    }
    
    func displayPhotosFound() {
        let numPhotos = self.currTour!.photos.count
        var numFound = self.currPhotoIndex!
        if self.finished {
            numFound = numPhotos
        }
        
        self.storiesFoundLabel.text = String(numFound) + " / " + String(numPhotos)
    }
    
    func displayDirectionsToCurrPhoto() {
        print("Fetching directions for route" )
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
        
        print("Drawing route")
        
        let pointCount = route.polyline.pointCount
        var points = [CLLocationCoordinate2D](repeating:CLLocationCoordinate2D(), count:pointCount)
        route.polyline.getCoordinates(&points, range: NSMakeRange(0, pointCount))
        
        for childNode in self.currDirectionsNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        guard let startCoor:CLLocation = locationManager.location
            else { return }
        
        var prevCoor:CLLocation = startCoor
        for coor in points {
            
            let direction = (coor.latitude - startCoor.coordinate.latitude,
                             coor.longitude - startCoor.coordinate.longitude)
            let rotate = Float(atan2(direction.0, direction.1)) + .pi/2
        
            let currCoor = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
            drawNodeOnRoute(loc: currCoor, dir: rotate)
            
            let dist = prevCoor.distance(from: currCoor)
            let divide = Int(ceil(dist / 10.0))
            let deltaLat = (currCoor.coordinate.latitude - prevCoor.coordinate.latitude) / Double(divide)
            let deltaLong = (currCoor.coordinate.longitude - prevCoor.coordinate.longitude) / Double(divide)
            
            for i in 1..<divide {
                let partialCoor = CLLocation(latitude: prevCoor.coordinate.latitude + deltaLat * Double(i),
                                             longitude: prevCoor.coordinate.longitude + deltaLong * Double(i))
                
                drawNodeOnRoute(loc: partialCoor, dir: rotate)
            }
            
            prevCoor = currCoor
        }
    }

    func drawNodeOnRoute(loc:CLLocation, dir:Float) {
        guard let currLoc:CLLocation = locationManager.location
            else{ return}
        
        let plane:SCNPlane = SCNPlane(width: 1.5, height: 1.5)
        plane.firstMaterial!.diffuse.contents = #imageLiteral(resourceName: "Direction")
        plane.firstMaterial!.emission.contents = #imageLiteral(resourceName: "Direction")
        plane.firstMaterial!.isDoubleSided = true
        
        let newNode = SCNNode(geometry: plane)
        let wrapperNode = SCNNode()
        wrapperNode.addChildNode(newNode)
        
        let nodeLoc = ARObjectManager.getARPosition(currLocCLL: currLoc, currLocAR: self.getARLocation(), objectLocCLL: loc)
        wrapperNode.position = nodeLoc
        
        newNode.eulerAngles = SCNVector3Make(.pi/2, dir, 0)
        
        
        self.currDirectionsNode.addChildNode(wrapperNode)
    }
    
    func updateY(newY:Float) {
        self.currDirectionsNode.position = SCNVector3Make(self.currDirectionsNode.position.x,
                                                          newY,
                                                          self.currDirectionsNode.position.z)
    }
    
    
    
}
