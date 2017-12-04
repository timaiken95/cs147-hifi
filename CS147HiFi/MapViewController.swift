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
    @IBOutlet weak var alreadySeenView: UIVisualEffectView!
    @IBOutlet weak var alreadySeenTitle: UILabel!
    @IBOutlet weak var alreadySeenDistance: UILabel!
    @IBOutlet weak var alreadySeenImage: UIImageView!
    
    @IBOutlet weak var notSeenView: UIVisualEffectView!
    @IBOutlet weak var notSeenDistance: UILabel!
    @IBOutlet weak var notSeenTitle: UILabel!
    
    @IBOutlet weak var tourInfoView: UIVisualEffectView!
    
    @IBOutlet weak var tourInfoTitle: UILabel!
    @IBOutlet weak var tourInfoDistToStart: UILabel!
    @IBOutlet weak var tourInfoEstimatedTime: UILabel!
    
    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.tourInfoView.isHidden = true
        self.alreadySeenView.isHidden = true
        self.notSeenView.isHidden = true
        
        self.locationManager = CLLocationManager()
        self.locationManager!.requestWhenInUseAuthorization()
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager!.distanceFilter = 1 // meters
        self.locationManager!.startUpdatingLocation()
        
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
            
            if UserDefaults.standard.object(forKey: "seen" + String(photo.photoID)) as! Bool {
                let pointAnnotation = CustomPin(location: photo.location.coordinate, pinImageStr: "pin_item_found.png", t: nil, p: photo)
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
            pinAnnotationView.canShowCallout = false;
            mapView.addAnnotation(pinAnnotationView.annotation!)
        }
        
        self.mapView.showsUserLocation = true
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPin
        annotationView?.image = UIImage(named: customPointAnnotation.pinImageName)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let info = view.annotation as? CustomPin
            else { return }
        
        if let p = info.photo {
            let loc = p.location
            let dist = locationManager!.location!.distance(from: loc) * 3.3 / 5280.0
            
            if UserDefaults.standard.object(forKey: "seen" + String(p.photoID)) as! Bool {
                self.alreadySeenImage.image = p.imageFile
                self.alreadySeenTitle.text = p.title
                self.alreadySeenDistance.text = "Distance from current location: " + String(format: "%.1f", dist) + " mi"
                self.alreadySeenView.isHidden = false
            } else {
                self.notSeenTitle.text = p.title
                self.notSeenDistance.text = "Distance from current location: " + String(format: "%.1f", dist) + " mi"
                self.notSeenView.isHidden = false
            }
        } else if let t = info.tour {
            
            let startPhoto = photos[t.photos[0]]!
            let dist = locationManager!.location!.distance(from: startPhoto.location) * 3.3 / 5280.0
            self.tourInfoTitle.text = t.title
            self.tourInfoDistToStart.text = "Distance to start: " + String(format: "%.1f", dist) + " mi"
            
            let totalTime = Int(t.estimatedTime + dist * 30)
            self.tourInfoEstimatedTime.text = "Estimated time: " + String(totalTime) + " min"
            
            self.tourInfoView.isHidden = false
        }
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAlreadySeenView(_ sender: Any) {
        self.alreadySeenView.isHidden = true
    }
    
    @IBAction func closeNotSeenView(_ sender: Any) {
        self.notSeenView.isHidden = true
    }
    
    @IBAction func closeTourInfoView(_ sender: Any) {
        self.tourInfoView.isHidden = true
    }
    
}
