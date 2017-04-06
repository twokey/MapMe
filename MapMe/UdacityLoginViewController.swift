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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up interface
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Check if logged in with Facebook
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        if FBSDKAccessToken.current() != nil {
            // If we have FB token continue to login
            loginWithFBToken(FBSDKAccessToken.current().tokenString)
        } else {
            // If we don't have FB token configure FB login button
            fbLoginButton.readPermissions = ["email"]
            fbLoginButton.delegate = self
        }
    }
    
    func loginWithFBToken(_ fbToken: String) {
        
        // Set up UI
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        // Get user ID using FB token
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
        
        
        // Login with user ID
        UdacityClient.sharedInstance().getUdacityUserPublicData(userID) { user, error in
            
            // TODO: Add guards for errors
            
            // Get reference to App Delegate where we keep our model
            if let user = user {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.user = user
            }
            
            // Get student's locations and links
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

                    // Save student information (annotations) in app delegate
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.annotations.append(annotation)
                }
                
                // We have user data, students data (annotations) we can continue to map VC
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "userAuthorized", sender: self)
                }
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func udacityLogin(_ sender: UIButton) {
        
        // Set up UI
 //       activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        
        guard let userName = userEmail.text else {
            print("userEmail text field is nil")
            return
        }
        
        guard let userPassword = userPassword.text else {
            print("userPassword is nil")
            return
        }
        
        // Login with Udacity credentials
        UdacityClient.sharedInstance().getUdacityStudentIDforUser(userName, userPassword: userPassword) { userID, error in
            
            if let userID = userID {
                guard let userID = Int(userID) else {
                    return
                }
                
                self.loginWithUserID(userID)
                
            }
        }
    }
    
}


    // MARK: FBSDK delegate

extension UdacityLoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        loginWithFBToken(FBSDKAccessToken.current().tokenString)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

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
