//
//  UdacityConstants.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-25.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let APIKey = "my_api_key"
        
        // MARK: URLs
        static let APIScheme = "https"
        static let udacityAPIHost = "www.udacity.com"
        static let udacityAPIPath = "/api"
        static let parseAPIHost = "parse.udacity.com"
        static let parseAPIPath = "/parse/classes"
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    struct JSONResponseKeys {
        static let account = "account"
        static let key = "key"
        static let session = "session"
        static let id = "id"
        static let results = "results"
        static let user = "user"
        static let userLastName = "last_name"
        static let userFirstName = "first_name"
        
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
    }
}
