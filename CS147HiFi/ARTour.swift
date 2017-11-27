//
//  ARTour.swift
//  CS147HiFi
//
//  Created by timaiken on 11/24/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

class ARTour {
    let tourID: Int
    let title: String
    let description: String
    let startLocation: CLLocation
    let endLocation: CLLocation
    let photos: [Int]
    let estimatedTime:TimeInterval
    
    init(tID:Int, t: String, d: String, startlat: Float, startlong: Float, endlat: Float, endlong: Float, ps:[Int], time:TimeInterval) {
        self.tourID = tID
        self.title = t
        self.description = d
        self.startLocation = CLLocation(latitude: Double(startlat), longitude: Double(startlong))
        self.endLocation = CLLocation(latitude: Double(endlat), longitude: Double(endlong))
        self.photos = ps
        self.estimatedTime = time
    }
    
}

