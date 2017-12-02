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
        
        let coor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.427498, longitude: -122.170265)
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.027, longitudeDelta: 0.027)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coor, span: span)
        
        mapView.setRegion(region, animated: false)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
