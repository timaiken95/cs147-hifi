//
//  ARAudio.swift
//  CS147HiFi
//
//  Created by Alyssa Vann on 12/3/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import CoreLocation

class ARAudio {
    let audioID: Int
    let audioFile: String
    let photoID: Int
    
    init(aID:Int, filename:String, photo:Int) {
        self.audioID = aID
        self.audioFile = filename
        self.photoID = photo
    }
}
