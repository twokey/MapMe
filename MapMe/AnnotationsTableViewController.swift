//
//  AnnotationsTableViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-28.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import SafariServices
import FBSDKLoginKit

class AnnotationsTableViewController: UITableViewController {
  
    
    // MARK: Properties
    
    var annotations: [MKAnnotation] {
        return (UIApplication.shared.delegate as! AppDelegate).annotations
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        self.navigationController?.view.addSubview(activityIndicator)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return annotations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnotationCellReuseIdentifier", for: indexPath)

        // Configure the cell
        let annotation = annotations[indexPath.row]
        
        cell.textLabel?.text = annotation.title!
        cell.detailTextLabel?.text = annotation.subtitle!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let annotation = annotations[indexPath.row]
        
        guard let urlAddress = annotation.subtitle as? String else {
            AllertViewController.showAlertWithTitle("URL Address", message: "No web address provided")
            return
        }
        
        var stringAddress = urlAddress
        
        if !(urlAddress.contains("https://") || urlAddress.contains("http://")) {
            stringAddress = "https://" + urlAddress
        }
        
        guard let url = URL(string: stringAddress) else {
            AllertViewController.showAlertWithTitle("URL Address", message: "URL is not valid")
            return
        }
        
        let safaryViewController = SFSafariViewController(url: url)
        
        self.present(safaryViewController, animated: true, completion: nil)
        
    }
    
    
    // MARK: Actions

    @IBAction func logout(_ sender: UIBarButtonItem) {

        // Logout from Facebook
        FBSDKLoginManager().logOut()
        
        // Logout from Udacity
        // Setup UI; Dim background
        activityIndicator.startAnimating()
        tableView.alpha = 0.5
        UdacityClient.sharedInstance().logoutUdacitySession() { sessionId, error in
            
            guard (error == nil) else {
                print(error ?? "Error was not provided")
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.tableView.alpha = 1.0
                    AllertViewController.showAlertWithTitle("Logout failed", message: "Couldn't logout. Please try again")
                }
                return
            }
            
            if let sessionId = sessionId {
                self.dismiss(animated: true, completion: nil)
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.tableView.alpha = 1.0
                    AllertViewController.showAlertWithTitle("Logout failed", message: "Couldn't logout. Unexpected response. Please try again")
                }
            }
        }
    }
    
    @IBAction func reloadStudentConnections(_ sender: UIBarButtonItem) {
        
        // Setup UI; dim background
        activityIndicator.startAnimating()
        tableView.alpha = 0.5

        
        // Get student's locations and links
        UdacityClient.sharedInstance().getStudents() { students, error in
            
            // Get reference to app delegate and clean students locations
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.annotations.removeAll()
            
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
                appDelegate.annotations.append(annotation)
            }
            
            // We have user data, students data (annotations) we can continue to map VC
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.tableView.alpha = 1.0
                self.tableView.reloadData()
            }
        }

    }
}
