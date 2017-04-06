//
//  ChooseLocationViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-28.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import CoreLocation

class ChooseLocationViewController: UIViewController {

    @IBOutlet weak var addressTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: Actions
    
    @IBAction func geocodeForward(_ sender: UIButton) {
        
        let geocoder = CLGeocoder()
        let userAddress = addressTextView.text!
        
        geocoder.geocodeAddressString(userAddress) {placemarks, error in
            
            guard let placemarks = placemarks, placemarks.count > 0 else {
                return
            }

            let studyLocation = placemarks[0].location
            
            performUIUpdatesOnMain{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let postLocationVC = storyboard.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
                postLocationVC.studyLocation = studyLocation
                postLocationVC.userAddress = userAddress
                
                self.navigationController?.pushViewController(postLocationVC, animated: true)
            }
        }
    }
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
