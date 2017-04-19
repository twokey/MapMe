//
//  StudentLocations.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-04-17.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import MapKit

class StudentLocations {
    
    
    // MARK: Properties
    var annotations: [MKPointAnnotation]
    
    // Shared instance
    static let sharedInstance = StudentLocations()

    
    // MARK: Initializers
    
    init() {
        annotations = []
    }

    
    func updateStudentLocations(_ students: [Student]) {
        
        annotations.removeAll()
        
        for student in students {

            // Create pin location from student coordinates
            let studentLat = student.latitude ?? 0
            let studentLong = student.longitude ?? 0
            let lat = CLLocationDegrees(studentLat)
            let long = CLLocationDegrees(studentLong)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let uniqueKey = student.uniqueKey ?? ""

            let first = student.firstName ?? ""
            let last = student.lastName ?? ""
            let mediaURL = student.mediaURL ?? ""

            // Create annotation from student info
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL

            // Save student information (annotations) in app delegate
            annotations.append(annotation)
        }
    }
    
}
