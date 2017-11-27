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
    let photos: [Int]
    let estimatedTime:TimeInterval
    
    init(tID:Int, t: String, d: String, ps:[Int], time:TimeInterval) {
        self.tourID = tID
        self.title = t
        self.description = d
        self.photos = ps
        self.estimatedTime = time
    }
    
}

