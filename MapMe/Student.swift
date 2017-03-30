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
    
}
