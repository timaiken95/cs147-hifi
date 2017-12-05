//
//  Data.swift
//  CS147HiFi
//
//  Created by timaiken on 11/22/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import UIKit

class AppData {
    class func importAllData(objectManager:ARObjectManager, tourManager:ARTourManager, audioManager:ARAudioManager) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for photo in appDelegate.photos {
            objectManager.addARItem(newPhoto: photo)
        }
        
        for audio in appDelegate.audio {
            audioManager.addARItem(newAudio: audio)
        }
        
        for tour in appDelegate.tours {
            tourManager.addARTour(newTour: tour)
        }
    }
}
