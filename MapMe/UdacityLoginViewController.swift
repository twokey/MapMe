//
//  UdacityLoginViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class UdacityLoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        if FBSDKAccessToken.current() != nil {
            print("Already logged in")
            print(FBSDKAccessToken.current().tokenString)
            loginWithFBToken(FBSDKAccessToken.current().tokenString)
        } else {
            fbLoginButton.readPermissions = ["email"]
            fbLoginButton.delegate = self
        }
        
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
                
                self.loginWithUserID(userID)
                
            }
        }
    }
    
    func loginWithFBToken(_ fbToken: String) {
        
        UdacityClient.sharedInstance().postSessionWithFacebookToken(fbToken) { userID, error in
                
            if let userID = userID {
                guard let userID = Int(userID) else {
                    return
                }
                
                self.loginWithUserID(userID)
            }
        }
    }
    
    func loginWithUserID(_ userID: Int) {
        
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
                
                performUIUpdatesOnMain {
                    self.performSegue(withIdentifier: "userAuthorized", sender: self)
                }
            }
        }
    }
    
}

extension UdacityLoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("logged in")
        print(FBSDKAccessToken.current().tokenString)
        loginWithFBToken(FBSDKAccessToken.current().tokenString)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    func logUserData() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest?.start() { connection, result, error in
            if error != nil {
                print(error!)
            } else {
               print(result!)
            }
            
        }
    }
    
}
