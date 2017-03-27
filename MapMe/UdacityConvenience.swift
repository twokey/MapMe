//
//  UdacityConvenience.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func getUdacitySessionIDforUser(_ userName: String, userPassword: String, completionHandlerForSessionID: @escaping (_ sessionID: String?, _ errorString: String?) -> Void) {
        
        let method = "/session"
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(userPassword)\"}}"
        
        let _ = UdacityClient.sharedInstance().taskForPOSTMethod(method, host: UdacityClient.Constants.udacityAPIHost, parameters: [:], jsonBody: jsonBody) { (data, error) in
            
            guard (error == nil) else {
                print(error)
                completionHandlerForSessionID(nil, "Login Failed (Session ID)")
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                completionHandlerForSessionID(nil, "Login Failed (No data)")
                return
            }
            
            guard let session = data[UdacityClient.JSONResponseKeys.session] as? NSDictionary else {
                print("Cannot find session dictionary")
                completionHandlerForSessionID(nil, "Login Failed (No session key)")
                return
            }
        
            guard let sessionID = session[UdacityClient.JSONResponseKeys.id] as? String else {
                print("No session ID was returned")
                completionHandlerForSessionID(nil, "Login Failed (No ID key)")
                return
            }
            
            completionHandlerForSessionID(sessionID, nil)
        }
    }
    
    func getStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ studentLocations: [StudentLocation]?, _ errorString: String?) -> Void) {
        
        let method = "/method"
        
        
    }
    
}
