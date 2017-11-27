//
//  Data.swift
//  CS147HiFi
//
//  Created by timaiken on 11/22/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation

class AppData {
    class func importAllData(objectManager:ARObjectManager, tourManager:ARTourManager) {
        objectManager.addARItem(photoId: 0, file: "slide13.png", title: "Wine", description: "wine :)", lat: 37.447126, long: -122.18545, tours: [0], scale: 1)
        
        tourManager.addARTour(tourID: 0, title: "blah", description: "blah", photos: [0], time: 10)
    }
}
