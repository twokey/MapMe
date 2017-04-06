//
//  AnnotationsTableViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-28.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit

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

        // Configure the cell...
        let annotation = annotations[indexPath.row]
        
        cell.textLabel?.text = annotation.title!
        cell.detailTextLabel?.text = annotation.subtitle!

        return cell
    }

    @IBAction func reloadStudentConnections(_ sender: UIBarButtonItem) {
        
        // Setup UI
        activityIndicator.startAnimating()
        
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
            }
        }

    }
}
