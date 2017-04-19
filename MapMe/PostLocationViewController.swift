//
//  PostLocationViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-28.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController {
    
    
    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextView: UITextView!
    
    
    // MARK: Properties

    var user = UserInformation.sharedInstance.user
    var studyLocation: CLLocation!
    var userAddress: String!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        linkTextView.delegate = self
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        navigationController?.view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set location of study address
        centerMapOnLocation(studyLocation)
    }
    
    
    // MARK: Helpers
    
    private func centerMapOnLocation(_ location: CLLocation, radius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius * 2.0, radius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // MARK: Actions

    @IBAction func postLocation(_ sender: UIButton) {
        
        let latitude = studyLocation.coordinate.latitude
        let longitude = studyLocation.coordinate.longitude
        let student = Student(uniqueKey: user.uniqueKey, firstName: user.firstName, lastName: user.lastName, mapString: userAddress, mediaURL: linkTextView.text!, latitude: latitude, longitude: longitude)
        
        activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance.postStudentLocationFor(student: student) { objectId, error in

            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    AllertViewController.showAlertWithTitle("Study Location", message: "Couldn't post student's study location. Please try again")
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
    
}


// MARK: - UITextView Delegate

extension PostLocationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
