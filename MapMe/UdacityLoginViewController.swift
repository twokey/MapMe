//
//  UdacityLoginViewController.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit

class UdacityLoginViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        UdacityClient.sharedInstance().getUdacitySessionIDforUser(userName, userPassword: userPassword) { sessionID, error in
            
            
            print(sessionID)
            
            
        }
        
    }
    
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.performSegue(withIdentifier: "userAuthorized", sender: self)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // print("We are about to show main screen")
    }


}
