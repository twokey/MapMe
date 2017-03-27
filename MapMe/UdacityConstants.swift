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
        static let parseAPIHost = ""
//        static let AuthorizationURL = "authorization_url"
//        static let AccountURL = "account_url"
    }
    
    struct ParameterKeys {
        static let APIKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    struct JSONResponseKeys {
        static let session = "session"
        static let id = "id"
    }
}
