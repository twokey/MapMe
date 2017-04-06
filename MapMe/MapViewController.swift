//
//  MapViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Properties
    
    var annotations: [MKAnnotation] {
        return (UIApplication.shared.delegate as! AppDelegate).annotations
    }    
    
    // Set initial location in Vancouver
    let initialLocation = CLLocation(latitude: 49.248526, longitude: -123.116009)
    let regionRadius: CLLocationDistance = 1000
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.addAnnotations(annotations)
        
    }
        
    // MARK: Helpers
    
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

extension MapViewController: MKMapViewDelegate {
    
}
