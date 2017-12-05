//
//  ARAudioManager.swift
//  CS147HiFi
//
//  Created by clmeiste on 12/4/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation

class ARAudioManager {
    
    var arAudio:[Int:ARAudio]
    
    init() {
        self.arAudio = [:]
    }
    
    func addARItem(newAudio:ARAudio) {
        self.arAudio[newAudio.photoID] = newAudio
    }
    
    
}
