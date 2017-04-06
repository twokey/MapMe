//
//  MapViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Properties
    
    var annotations: [MKAnnotation] {
        return (UIApplication.shared.delegate as! AppDelegate).annotations
    }    
    
    // Set initial location in Vancouver
    let initialLocation = CLLocation(latitude: 49.248526, longitude: -123.116009)
    let regionRadius: CLLocationDistance = 1000
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup map view
        mapView.addAnnotations(annotations)
        
        // Setup UI
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
    }
        
    // MARK: Helpers
    
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func reloadStudentLocations(_ sender: UIBarButtonItem) {
        
        // Setup UI
        activityIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        
        // Get student's locations and links
        UdacityClient.sharedInstance().getStudents() { students, error in
            
            // Get reference to app delegate and clean students locations
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.annotations.removeAll()


            guard let students = students else {
                return
            }
            
            for student in students {
                
                // Create pin location from student coordinates
                let studentLat = student.latitude ?? 0
                let studentLong = student.longitude ?? 0
                let lat = CLLocationDegrees(studentLat)
                let long = CLLocationDegrees(studentLong)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = student.firstName ?? ""
                let last = student.lastName ?? ""
                let mediaURL = student.mediaURL ?? ""
                
                // Create annotation from student info
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Save student information (annotations) in app delegate
                appDelegate.annotations.append(annotation)
            }
            
            // We have user data, students data (annotations) we can continue to map VC
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.mapView.addAnnotations(self.annotations)

            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
}
