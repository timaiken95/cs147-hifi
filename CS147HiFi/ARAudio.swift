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
    let audioPhoto: String
    
    var visible: Bool
//    var visible:Bool {
//        set {
//            if newValue == true {
//                self.geometryNode.isHidden = false
//            } else {
//                self.geometryNode.isHidden = true
//            }
//        }
//
//        get {
//            return self.visible
//        }
//    }
    
    init(aID:Int, filename:String, photo:String) {
        self.audioID = aID
        self.audioFile = filename
        self.audioPhoto = photo
        
        if let _ = UserDefaults.standard.object(forKey: "seen" + String(aID)) as? Bool {
            print("it worked")
        } else {
            UserDefaults.standard.set(false, forKey: "seen" + String(aID))
        }
        
        // set this last
        self.visible = true
    }
}
