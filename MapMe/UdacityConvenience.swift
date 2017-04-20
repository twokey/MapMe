//
//  UdacityConvenience.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

extension UdacityClient {

    func postSessionWithFacebookToken(_ token: String, completionHandlerForPostSession: @escaping (_ resul: String?, _ error: NSError?) -> Void) {
        
        let method = "/session"
        let url = udacityURLFromParameters([:], withPathExtension: method)
        let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}"
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let _ = UdacityClient.sharedInstance.taskForUdacityPOSTRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPostSession(nil, NSError(domain: "postSessionWithFacebookToken", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let accountDictionary = parsedResult[UdacityClient.JSONResponseKeys.account] as? NSDictionary else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.account)")
                return
            }
            
            guard let studentID = accountDictionary[UdacityClient.JSONResponseKeys.key] as? String else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.id)")
                return
            }
            
            completionHandlerForPostSession(studentID, nil)
        }
    }
    
    func getUdacityUserPublicData(_ userId: Int, completionHandlerForUserPublicData: @escaping (_ student: Student?, _ error: NSError?) -> Void) {

        let method = "/users/\(userId)"
        
        let url = udacityURLFromParameters([:], withPathExtension: method)

        let request = NSMutableURLRequest(url: url)
        
        let _ = UdacityClient.sharedInstance.taskForUdacityPOSTRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForUserPublicData(nil, NSError(domain: "getUdacityUserPublicData", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let user = parsedResult[UdacityClient.JSONResponseKeys.user] as? NSDictionary else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.user)")
                return
            }
            
            guard let firstName = user[UdacityClient.JSONResponseKeys.userFirstName] as? String else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.userFirstName)")
                return
            }
            
            guard let lastName = user[UdacityClient.JSONResponseKeys.userLastName] as? String else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.userLastName)")
                return
            }
            
            let uniqueKey = String(userId)
            
            let student = Student(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName)
            
            completionHandlerForUserPublicData(student, nil)
        }
    }

    // Login with Udacity credentials
    func getUdacityStudentIDforUser(_ userName: String, userPassword: String, completionHandlerForSessionID: @escaping (_ studentID: String?, _ error: NSError?) -> Void) {
        
        let method = "/session"
        let url = udacityURLFromParameters([:], withPathExtension: method)
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(userPassword)\"}}"
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let _ = UdacityClient.sharedInstance.taskForUdacityPOSTRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForSessionID(nil, NSError(domain: "getUdacitySessionIDforUser", code: code, userInfo: userInfo))
            }

            if let error = error {
                sendError("There was an error with your request: \(error)", code: error.code)
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned", code: 2)
                return
            }
            
            guard let accountDictionary = parsedResult[UdacityClient.JSONResponseKeys.account] as? NSDictionary else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.account)", code: 3)
                return
            }
        
            guard let studentID = accountDictionary[UdacityClient.JSONResponseKeys.key] as? String else {
                sendError("Login Failed no JSON key found: \(UdacityClient.JSONResponseKeys.id)", code: 4)
                return
            }
            
            completionHandlerForSessionID(studentID, nil)
        }
    }
    
    // Logut with Udacity credentials
    func logoutUdacitySession(_ completionHandlerForSessionID: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        let method = "/session"
        let url = udacityURLFromParameters([:], withPathExtension: method)
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let _ = UdacityClient.sharedInstance.taskForUdacityPOSTRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForSessionID(nil, NSError(domain: "getUdacitySessionIDforUser", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let accountDictionary = parsedResult[UdacityClient.JSONResponseKeys.session] as? NSDictionary else {
                sendError("Logout failed no JSON key found: \(UdacityClient.JSONResponseKeys.session)")
                return
            }
            
            guard let sessionId = accountDictionary[UdacityClient.JSONResponseKeys.id] as? String else {
                sendError("Logout failed no JSON key found: \(UdacityClient.JSONResponseKeys.id)")
                return
            }
            
            completionHandlerForSessionID(sessionId, nil)
        }
    }

    // Download students locations
    func getStudents(_ completionHandlerForStudentLocations: @escaping (_ students: [Student]?, _ errorString: NSError?) -> Void) {
        
        let method = "/StudentLocation"
        let params = ["limit": 100, "order": "-updatedAt"] as [String : AnyObject]
        let url = parseURLFromParameters(params, withPathExtension: method)
        print(url)
        let request = NSMutableURLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let _ = UdacityClient.sharedInstance.taskForParseGETRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForStudentLocations(nil, NSError(domain: "getStudents", code: 999, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let studentsArrayOfDictionaries = parsedResult[UdacityClient.JSONResponseKeys.results] as? [[String:AnyObject]] else {
                print("Cannot find key \(UdacityClient.JSONResponseKeys.results)")
                return
            }
            
            var students = [Student]()
            
            for (_, student) in studentsArrayOfDictionaries.enumerated() {
                
                let createdAt = student[UdacityClient.JSONResponseKeys.createdAt] as? String
                let firstName = student[UdacityClient.JSONResponseKeys.firstName] as? String
                let lastName = student[UdacityClient.JSONResponseKeys.lastName] as? String
                let latitude = student[UdacityClient.JSONResponseKeys.latitude] as? Double
                let longitude = student[UdacityClient.JSONResponseKeys.longitude] as? Double
                let mapString = student[UdacityClient.JSONResponseKeys.mapString] as? String
                let mediaURL = student[UdacityClient.JSONResponseKeys.mediaURL] as? String
                let objectId = student[UdacityClient.JSONResponseKeys.objectId] as? String
                let uniqueKey = student[UdacityClient.JSONResponseKeys.uniqueKey] as? String
                let updatedAt = student[UdacityClient.JSONResponseKeys.updatedAt] as? String
                
                let student = Student(objectId: objectId,
                                      uniqueKey: uniqueKey,
                                      firstName: firstName,
                                      lastName: lastName,
                                      mapString: mapString,
                                      mediaURL: mediaURL,
                                      latitude: latitude,
                                      longitude: longitude,
                                      createdAt: createdAt,
                                      updatedAt: updatedAt)
                
                students.append(student)
            }
            
            completionHandlerForStudentLocations(students, nil)
            
        }
        
    }
    
    // Post student location
    func postStudentLocationFor(student: Student, completionHandlerForPostStudentLocation: @escaping (_ students: String?, _ errorString: NSError?) -> Void) {
        
        let method = "/StudentLocation"
        let url = parseURLFromParameters([:], withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBodyForPostStudentLocation(student).data(using: String.Encoding.utf8)
        let _ = UdacityClient.sharedInstance.taskForParseGETRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPostStudentLocation(nil, NSError(domain: "postStudentLocationFor", code: 999, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let postedLocationDictionary = parsedResult as? [String:AnyObject] else {
                print("Cannot find key \(UdacityClient.JSONResponseKeys.results)")
                return
            }
            
            guard let objectID = postedLocationDictionary[UdacityClient.JSONResponseKeys.objectId] as? String else {
                sendError("Cannot find key \(UdacityClient.JSONResponseKeys.objectId)")
                return
            }
            
            completionHandlerForPostStudentLocation(objectID, nil)
        }
    }

    
    // MARK: Helpers
    
    private func udacityURLFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.APIScheme
        components.host = UdacityClient.Constants.udacityAPIHost
        components.path = UdacityClient.Constants.udacityAPIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func parseURLFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.APIScheme
        components.host = UdacityClient.Constants.parseAPIHost
        components.path = UdacityClient.Constants.parseAPIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func httpBodyForPostStudentLocation(_ student: Student) -> String {

        //let createdAt = student.createdAt
        let firstName = student.firstName!
        let lastName = student.lastName!
        let latitude = student.latitude!
        let longitude = student.longitude!
        let mapString = student.mapString!
        let mediaURL = student.mediaURL!
        //let objectId = student.objectID!
        let uniqueKey = student.uniqueKey!
        //let updatedAt = student.updatedAt!
        
        let httpBody = "{\"uniqueKey\": \"\(uniqueKey)\",\"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        return httpBody
    }

}
