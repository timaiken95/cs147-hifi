//
//  CustomPin.swift
//  CS147HiFi
//
//  Created by clmeiste on 12/1/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import UIKit
import MapKit

class CustomPin: MKPointAnnotation {
    let pinImageName:String
    open var loc:CLLocationCoordinate2D
    let tour:ARTour?
    let photo:ARPhoto?
    
    init(location:CLLocationCoordinate2D, pinImageStr:String, t:ARTour?, p:ARPhoto?) {
        
        self.loc = location
        self.pinImageName = pinImageStr
        self.tour = t
        self.photo = p
        
        super.init()
        super.coordinate = location
    }
}
