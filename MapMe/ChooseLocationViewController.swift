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
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        addressTextView.delegate = self
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        navigationController?.view.addSubview(activityIndicator)
        
        linkLabel.isHidden = true
        linkTextView.isHidden = true
        postLocationButton.isHidden = true
        mapView.isHidden = true
    }

    
    // MARK: Actions
    
    @IBAction func geocodeForward(_ sender: UIButton) {
        
        let geocoder = CLGeocoder()
        let userAddress = addressTextView.text!

        activityIndicator.startAnimating()
        
        
        geocoder.geocodeAddressString(userAddress) {placemarks, error in
            
            guard let placemarks = placemarks, placemarks.count > 0 else {
                
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    AllertViewController.showAlertWithTitle("Location", message: "Location was not identified")
                }
                return
            }

            let studyLocation = placemarks[0].location
            
            performUIUpdatesOnMain{
                
                self.activityIndicator.stopAnimating()
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
                                                    },
                                                   completion: nil)
                                }


//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let postLocationVC = storyboard.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
//                postLocationVC.studyLocation = studyLocation
//                postLocationVC.userAddress = userAddress
//                
//                self.navigationController?.pushViewController(postLocationVC, animated: true)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }

}

    // MARK: - UITextView Delegate

extension ChooseLocationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
