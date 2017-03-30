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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        centerMapOnLocation(initialLocation)
    }
    
    // MARK: Helpers
    
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension MapViewController: MKMapViewDelegate {
    
}
