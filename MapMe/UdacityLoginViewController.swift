//
//  UdacityLoginViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import FBSDKLoginKit

class UdacityLoginViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var udacityLoginButton: UIButton!
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
    
    
    // MARK: Login
    
    func loginWithUserID(_ userID: Int) {
        
        
        // Login with user ID
        UdacityClient.sharedInstance().getUdacityUserPublicData(userID) { user, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("User Profile", message: "Cannot get user profile information. Try again")
                }
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            // Get reference to App Delegate where we keep our model
            if let user = user {
                appDelegate.user = user
            }
            
            // Get student's locations and links; We will need them for next VC and a user is waiting anyway
            UdacityClient.sharedInstance().getStudents() { students, error in

                guard (error == nil) else {
                    print(error ?? "Error was not provided")
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students' locations")
                    }
                    return
                }
                
                guard let students = students else {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
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
                
                // We have user data, students data (annotations) we can continue to map VC
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    self.performSegue(withIdentifier: "userAuthorized", sender: self)
                }
            }
        }
    }
    
    func loginWithFBToken(_ fbToken: String) {
        
        // Setup UI
        activityIndicator.startAnimating()
        interfaceDimmed(true)
        
        // Get user ID using FB token
        UdacityClient.sharedInstance().postSessionWithFacebookToken(fbToken) { userID, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("Facebook Login", message: "Cannot login with Facebook")
                }
                return
            }
            
            if let userID = userID {
                guard let userID = Int(userID) else {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        AllertViewController.showAlertWithTitle("User ID", message: "User ID is not Int")
                    }
                    return
                }
                
                self.loginWithUserID(userID)
            }
        }
    }
    
    
    // MARK: UI setup helpers
    
    func interfaceDimmed(_ state: Bool) {
        
        if state {
            // Disable and dim interface
            let alpha = CGFloat(0.5)
            userEmail.isEnabled = !state
            userEmail.alpha = alpha
            userPassword.isEnabled = !state
            userPassword.alpha = alpha
            fbLoginButton.isEnabled = !state
            fbLoginButton.alpha = alpha
            udacityLoginButton.isEnabled = !state
            udacityLoginButton.alpha = alpha
        } else {
            // Enable interface
            let alpha = CGFloat(1)
            userEmail.isEnabled = !state
            userEmail.alpha = alpha
            userPassword.isEnabled = !state
            userPassword.alpha = alpha
            fbLoginButton.isEnabled = !state
            fbLoginButton.alpha = alpha
            udacityLoginButton.isEnabled = !state
            udacityLoginButton.alpha = alpha
        }
    }
    
    
    // MARK: Actions
    
    // Login with Udacity credentials
    @IBAction func udacityLogin(_ sender: UIButton) {
        
        guard let userName = userEmail.text, userName != "" else {
            AllertViewController.showAlertWithTitle("Account", message: "Please enter Udacity email")
            return
        }
        
        guard let userPassword = userPassword.text, userPassword != "" else {
            AllertViewController.showAlertWithTitle("Password", message: "Please enter password for Udacity account")
            return
        }

        // Setup UI
        activityIndicator.startAnimating()
        interfaceDimmed(true)

        // Login with Udacity credentials
        UdacityClient.sharedInstance().getUdacityStudentIDforUser(userName, userPassword: userPassword) { userID, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("User ID", message: "Cannot get user ID. Try again")
                }
                return
            }
            
            if let userID = userID {
                guard let userID = Int(userID) else {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        AllertViewController.showAlertWithTitle("User ID", message: "User ID is not Int")
                    }
                    return
                }
                
                self.loginWithUserID(userID)
            }
        }
    }
    
    @IBAction func udacitySignUp(_ sender: UIButton) {
        let safaryViewController = SFSafariViewController(url: URL(string: "https://www.udacity.com/account/auth#!/signup")!)
        present(safaryViewController, animated: true, completion: nil)
        
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
                print(error ?? "Error was not provided")
            } else {
               print(result ?? "No result provided")
            }
        }
    }
    
}
