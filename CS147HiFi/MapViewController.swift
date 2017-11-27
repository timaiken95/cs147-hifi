//
//  MapViewController.swift
//  CS147HiFi
//
//  Created by clmeiste on 11/27/17.
//  Copyright © 2017 StanfordX. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
