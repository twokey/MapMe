//
//  StudentLocationsMapViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import FBSDKLoginKit

class StudentLocationsMapViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Properties
    
    var annotations: [MKAnnotation] {
        return StudentLocations.sharedInstance.annotations
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
        mapView.alpha = 0.5
        
        // Get student's locations and links
        UdacityClient.sharedInstance.getStudents() { students, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.mapView.alpha = 1.0
                    self.mapView.addAnnotations(self.annotations)
                    AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students' locations. Try again")
                }
                return
            }
            
            if let students = students {
                
                StudentLocations.sharedInstance.updateStudentLocations(students)
                // We have students data (annotations) update annotations
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.mapView.alpha = 1.0
                    self.mapView.addAnnotations(self.annotations)
                    
                }
             
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.mapView.alpha = 1.0
                    self.mapView.addAnnotations(self.annotations)
                    AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students locations")
                }
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
        
        UdacityClient.sharedInstance.logoutUdacitySession() { sessionId, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    dimView.removeFromSuperview()
                    AllertViewController.showAlertWithTitle("Logout failed", message: "Couldn't logout. Please try again")
                }
                return
            }
            
            if let _ = sessionId {
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

extension StudentLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
        
        guard let urlAddress = annotationView.annotation?.subtitle as? String else {
            AllertViewController.showAlertWithTitle("URL Address", message: "No web address provided")
            return
        }
        
        var stringAddress = urlAddress
        
        if !(urlAddress.contains("https://") || urlAddress.contains("http://")) {
            stringAddress = "https://" + urlAddress
        }
        
        if let url = URL(string: stringAddress) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            AllertViewController.showAlertWithTitle("URL Address", message: "URL is not valid")
        }
        
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
