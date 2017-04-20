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
        userPassword.delegate = self
        userEmail.delegate = self
        
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
        UdacityClient.sharedInstance.getUdacityUserPublicData(userID) { user, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("User Profile", message: "Cannot get user profile information. Try again")
                }
                return
            }
            
            if let user = user {
                UserInformation.sharedInstance.user = user
            }
            
            // Get student's locations and links; We will need them for next VC and a user is waiting anyway
            UdacityClient.sharedInstance.getStudents() { students, error in

                guard (error == nil) else {
                    print(error ?? "Error was not provided")
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students' locations")
                    }
                    return
                }
                
                if let students = students {
                    
                    StudentLocations.sharedInstance.updateStudentLocations(students)
                    
                    // We have user data, students data (annotations) we can continue to map VC
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        self.performSegue(withIdentifier: "userAuthorized", sender: self)
                    }

                } else {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.interfaceDimmed(false)
                        AllertViewController.showAlertWithTitle("Students Data", message: "Cannot download students locations")
                    }
                }
            }
        }
    }
    
    func loginWithFBToken(_ fbToken: String) {
        
        // Setup UI
        activityIndicator.startAnimating()
        interfaceDimmed(true)
        
        // Get user ID using FB token
        UdacityClient.sharedInstance.postSessionWithFacebookToken(fbToken) { userID, error in
            
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
        UdacityClient.sharedInstance.getUdacityStudentIDforUser(userName, userPassword: userPassword) { userID, error in

            if let error = error {
                print(error)
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    if error.code == 403 {
                        AllertViewController.showAlertWithTitle("Login failed", message: "The user name or password is incorrect")
                    } else {
                        AllertViewController.showAlertWithTitle("Connection failed", message: "Cannot get user ID from a server. Try again")
                    }
                }
                return
            }

            guard let userID = userID else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("User ID", message: "User ID is not available. Try again")
                }
                return
            }
            
            if let userIDInt = Int(userID) {
                self.loginWithUserID(userIDInt)
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.interfaceDimmed(false)
                    AllertViewController.showAlertWithTitle("User ID", message: "User ID is not Int")
                }
            }
        }
    }
    
    // Link to sign up for the Udacity account
    @IBAction func udacitySignUp(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
}


// MARK: - FBSDK Delegate

extension UdacityLoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        loginWithFBToken(FBSDKAccessToken.current().tokenString)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }
        
}
