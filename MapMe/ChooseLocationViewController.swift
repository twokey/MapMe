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

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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

}
