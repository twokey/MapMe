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


    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

}
