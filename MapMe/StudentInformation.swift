//
//  Student.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

struct Student {
    
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String?
    let updatedAt: String?
    
    init() {
        self.objectId = nil
        self.uniqueKey = nil
        self.firstName = nil
        self.lastName = nil
        self.mapString = nil
        self.mediaURL = nil
        self.latitude = nil
        self.longitude = nil
        self.createdAt = nil
        self.updatedAt = nil
    }
    
    init(objectId: String? = nil, uniqueKey: String? = nil, firstName: String? = nil, lastName: String? = nil, mapString: String? = nil, mediaURL: String? = nil, latitude: Double? = nil, longitude: Double? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
    
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init (_ studentInformation: [String: AnyObject?]) {
        
        self.objectId = studentInformation[UdacityClient.JSONResponseKeys.objectId] as? String
        self.uniqueKey = studentInformation[UdacityClient.JSONResponseKeys.uniqueKey] as? String
        self.firstName = studentInformation[UdacityClient.JSONResponseKeys.firstName] as? String
        self.lastName = studentInformation[UdacityClient.JSONResponseKeys.lastName] as? String
        self.mapString = studentInformation[UdacityClient.JSONResponseKeys.mapString] as? String
        self.mediaURL = studentInformation[UdacityClient.JSONResponseKeys.mediaURL] as? String
        self.latitude = studentInformation[UdacityClient.JSONResponseKeys.latitude] as? Double
        self.longitude = studentInformation[UdacityClient.JSONResponseKeys.longitude] as? Double
        self.createdAt = studentInformation[UdacityClient.JSONResponseKeys.createdAt] as? String
        self.updatedAt = studentInformation[UdacityClient.JSONResponseKeys.updatedAt] as? String
        
    }
    
}
