//
//  UdacityLoginViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit

class UdacityLoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        self.performSegue(withIdentifier: "userAuthorized", sender: self)
        
    }
    
    @IBAction func getStudentsLocation(_ sender: UIButton) {
        
        guard let userName = userEmail.text else {
            print("userEmail text field is nil")
            return
        }
        
        guard let userPassword = userPassword.text else {
            print("userPassword is nil")
            return
        }
        
        UdacityClient.sharedInstance().getUdacityStudentIDforUser(userName, userPassword: userPassword) { userID, error in
            
            if let userID = userID {
                guard let userID = Int(userID) else {
                    return
                }
                
                UdacityClient.sharedInstance().getUdacityUserPublicData(userID) { user, error in
                    
                    if let user = user {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.user = user
                    }
                    
                    
                    UdacityClient.sharedInstance().getStudents() { students, error in
                        
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
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.annotations.append(annotation)
                        }
                        
                        self.completeLogin()
                    }
                }
            }
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.performSegue(withIdentifier: "userAuthorized", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // print("We are about to show main screen")
    }
    
    
}
