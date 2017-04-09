//
//  MapViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import FBSDKLoginKit

class MapViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Properties
    
    var annotations: [MKAnnotation] {
        return (UIApplication.shared.delegate as! AppDelegate).annotations
    }    
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup map view
        mapView.delegate = self
        mapView.addAnnotations(annotations)
        
        // Setup UI
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
    }

    // MARK: Actions
    
    @IBAction func reloadStudentLocations(_ sender: UIBarButtonItem) {
        
        // Setup UI
        activityIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.5
        dimView.frame = mapView.frame
        view.addSubview(dimView)
        
        // Get student's locations and links
        UdacityClient.sharedInstance().getStudents() { students, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    dimView.removeFromSuperview()
                    self.mapView.addAnnotations(self.annotations)
                    AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students' locations. Try again")
                }
                return
            }
            
            // Get reference to app delegate and clean students locations
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.annotations.removeAll()


            guard let students = students else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    dimView.removeFromSuperview()
                    AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students locations")
                }
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
            
            // We have students data (annotations) update annotations
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                dimView.removeFromSuperview()
                self.mapView.addAnnotations(self.annotations)

            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        
        FBSDKLoginManager().logOut()
        
        // Setup UI; Dim background
        activityIndicator.startAnimating()
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.5
        dimView.frame = mapView.frame
        view.addSubview(dimView)
        
        UdacityClient.sharedInstance().logoutUdacitySession() { sessionId, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    dimView.removeFromSuperview()
                    AllertViewController.showAlertWithTitle("Logout failed", message: "Couldn't logout. Please try again")
                }
                return
            }
            
            if let sessionId = sessionId {
                self.dismiss(animated: true, completion: nil)
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    dimView.removeFromSuperview()
                    AllertViewController.showAlertWithTitle("Logout failed", message: "Couldn't logout. Unexpected response. Please try again")
                }
            }
        }
    }
    
    
    
}

    // MARK: - MapView Delegatedd

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
        
        guard let urlAddress = annotationView.annotation?.subtitle as? String else {
            AllertViewController.showAlertWithTitle("URL Address", message: "No web address provided")
            return
        }
        
        var stringAddress = urlAddress
        
        if !(urlAddress.contains("https://") || urlAddress.contains("http://")) {
            stringAddress = "https://" + urlAddress
        }
        
        guard let url = URL(string: stringAddress) else {
            AllertViewController.showAlertWithTitle("URL Address", message: "URL is not valid")
            return
        }
        
        let safaryViewController = SFSafariViewController(url: url)
        
        self.present(safaryViewController, animated: true, completion: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let deqeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            deqeuedView.annotation = annotation
            view = deqeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let pinColor = UIColor(red: 0.98, green: 0.8549, blue: 0.2, alpha: 1.0)
            view.pinTintColor = pinColor
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIView
        }
        
        return view
    }
    
}
