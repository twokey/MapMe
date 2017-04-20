//
//  ChooseLocationViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-28.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ChooseLocationViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var postLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Properties
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var studyLocation: CLLocation!
    var userAddress: String!
    var user: Student {
        return UserInformation.sharedInstance.user
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        addressTextView.delegate = self
        linkTextView.delegate = self
        self.hideKeyboard()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        navigationController?.view.addSubview(activityIndicator)
        
        // Hide map and filed to post address until location is specified
        linkLabel.isHidden = true
        linkTextView.isHidden = true
        postLocationButton.isHidden = true
        mapView.isHidden = true
    }
    
    
    // MARK: Actions
    
    // Find coordinates for the study location address
    @IBAction func geocodeForward(_ sender: UIButton) {
        
        let geocoder = CLGeocoder()
        userAddress = addressTextView.text!

        activityIndicator.startAnimating()
        
        // Reverse geocogin for the study location address
        geocoder.geocodeAddressString(userAddress) {placemarks, error in
            
            guard let placemarks = placemarks, placemarks.count > 0 else {
                
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    AllertViewController.showAlertWithTitle("Location", message: "Location was not identified")
                }
                return
            }

            self.studyLocation = placemarks[0].location
            
            performUIUpdatesOnMain{
                
                self.activityIndicator.stopAnimating()
                // Hide field to find a study location and show views to post the study location
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: .curveEaseOut,
                               animations: {
                                    self.studyLabel.isHidden = true
                                    self.addressTextView.isHidden = true
                                    self.findLocationButton.isHidden = true
                                }) {_ in
                                    UIView.animate(withDuration: 0.3,
                                                   delay: 0,
                                                   options: .curveEaseOut,
                                                   animations: {
                                                        self.linkLabel.isHidden = false
                                                        self.linkTextView.isHidden = false
                                                        self.postLocationButton.isHidden = false
                                                        self.mapView.isHidden = false
                                                        self.centerMapOnLocation(self.studyLocation)
                                                    },
                                                   completion: nil)}

            }
        }
    }

    // Post study location to the Udacity server
    @IBAction func postStudyLocation(_ sender: UIButton) {
        let latitude = studyLocation.coordinate.latitude
        let longitude = studyLocation.coordinate.longitude
        let student = Student(uniqueKey: user.uniqueKey, firstName: user.firstName, lastName: user.lastName, mapString: userAddress, mediaURL: linkTextView.text!, latitude: latitude, longitude: longitude)
        
        activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance.postStudentLocationFor(student: student) { objectId, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    AllertViewController.showAlertWithTitle("Study Location", message: "Error while posting student's study location. Please try again")
                }
                return
            }
            
            if let _ = objectId {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) in
                        self.parent?.dismiss(animated: true, completion: nil)
                    }
                    let alert = UIAlertController(title: "New Location", message: "New study location has been submited successfuly", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(okAction)
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    AllertViewController.showAlertWithTitle("Study Location", message: "Couldn't post student's study location. Please try again")
                }
            }
        }
    }
    
    
    // MARK: Helpers
    
    private func centerMapOnLocation(_ location: CLLocation, radius: CLLocationDistance = 1000) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius * 2.0, radius * 2.0)
                mapView.setRegion(coordinateRegion, animated: true)
        
        let studyLocationAnnotation = MKPointAnnotation()
        studyLocationAnnotation.coordinate = location.coordinate
        studyLocationAnnotation.title = "\(UserInformation.sharedInstance.user.firstName!)"
        studyLocationAnnotation.subtitle = "Is studying here"

        mapView.addAnnotation(studyLocationAnnotation)
    }
    
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UITextView Delegate

extension ChooseLocationViewController: UITextViewDelegate {
    
    // Clear text view on beging editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    // Dissmiss keyboard on Enter
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }
}
