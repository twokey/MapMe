//
//  UserInformation.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-04-17.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

class UserInformation {
    
    // MARK: Properties
    var user: Student
    
    // Shared instance to access model
    static let sharedInstance = UserInformation()
    
    
    // MARK: Initializers
    init() {
        user = Student()
    }
}
