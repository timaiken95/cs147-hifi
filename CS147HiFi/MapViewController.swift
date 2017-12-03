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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var photos:[Int:ARPhoto] = [:]
    var tours:[Int:ARTour] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let coor:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.427498, longitude: -122.170265)
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.027, longitudeDelta: 0.027)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coor, span: span)
        
        mapView.setRegion(region, animated: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        for photo in appDelegate.photos {
            
            self.photos[photo.photoID] = photo
            
            var shouldContinue:Bool = false
            for tour in appDelegate.tours {
                if photo.photoID == tour.photos[0] {
                    shouldContinue = true
                }
            }
            if shouldContinue { continue }
        
            if UserDefaults.standard.object(forKey: "seen" + String(photo.photoID))! as! Bool {
                let pointAnnotation = CustomPin(location: photo.location.coordinate, pinImageStr: "pin_item_found_symbol", t: nil, p: photo)
                let pinAnnotationView:MKPinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
                mapView.addAnnotation(pinAnnotationView.annotation!)
            } else {
                let pointAnnotation = CustomPin(location: photo.location.coordinate, pinImageStr: "pin_item.png", t: nil, p: photo)
                let pinAnnotationView:MKPinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
                mapView.addAnnotation(pinAnnotationView.annotation!)
            }

        }
        
        for tour in appDelegate.tours {
            self.tours[tour.tourID] = tour
            let loc = self.photos[tour.photos[0]]!.location.coordinate
            
            let pointAnnotation = CustomPin(location: loc, pinImageStr: "pin_tour.png", t: tour, p: nil)
            let pinAnnotationView:MKPinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            mapView.addAnnotation(pinAnnotationView.annotation!)
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPin
        annotationView?.image = UIImage(named: customPointAnnotation.pinImageName)
        
        return annotationView
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
