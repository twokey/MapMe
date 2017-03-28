//
//  UdacityConvenience.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-26.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func getUdacitySessionIDforUser(_ userName: String, userPassword: String, completionHandlerForSessionID: @escaping (_ sessionID: String?, _ error: NSError?) -> Void) {
        
        let method = "/session"
        let jsonBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(userPassword)\"}}"
        
        let url = udacityURLFromParameters([:], withPathExtension: method)
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let _ = UdacityClient.sharedInstance().taskForUdacityPOSTRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForSessionID(nil, NSError(domain: "getUdacitySessionIDforUser", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let parsedResult = parsedResult as? NSDictionary else {
                sendError("No parsed result was returned")
                return
            }
            
            guard let session = parsedResult[UdacityClient.JSONResponseKeys.session] as? NSDictionary else {
                sendError("Login Failed no key \(UdacityClient.JSONResponseKeys.session)")
                return
            }
        
            guard let sessionID = session[UdacityClient.JSONResponseKeys.id] as? String else {
                sendError("Login Failed no key \(UdacityClient.JSONResponseKeys.id)")
                return
            }
            
            completionHandlerForSessionID(sessionID, nil)
        }
    }
    
    func getStudents(_ completionHandlerForStudentLocations: @escaping (_ students: [Student]?, _ errorString: NSError?) -> Void) {
        
        let method = "/StudentLocation"
        let url = parseURLFromParameters([:], withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let _ = UdacityClient.sharedInstance().taskForParseGETRequest(request) { (parsedResult, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForStudentLocations(nil, NSError(domain: "getStudents", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
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
                
                let student = Student(objectID: objectId,
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

    
}

//                guard let createdAt = student[UdacityClient.JSONResponseKeys.createdAt] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.createdAt)' in \(student)")
//                    return
//                }
//
//                guard let firstName = student[UdacityClient.JSONResponseKeys.firstName] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.firstName)' in \(student)")
//                    return
//                }
//                guard let lastName = student[UdacityClient.JSONResponseKeys.lastName] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.lastName)' in \(student)")
//                    return
//                }
//                guard let latitude = student[UdacityClient.JSONResponseKeys.latitude] as? Double else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.latitude)' in \(student)")
//                    return
//                }
//                guard let longitude = student[UdacityClient.JSONResponseKeys.longitude] as? Double else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.longitude)' in \(student)")
//                    return
//                }
//
//                guard let mapString = student[UdacityClient.JSONResponseKeys.mapString] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.mapString)' in \(student)")
//                    return
//                }
//
//                guard let mediaURL = student[UdacityClient.JSONResponseKeys.mediaURL] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.mediaURL)' in \(student)")
//                    return
//                }
//
//                guard let objectId = student[UdacityClient.JSONResponseKeys.objectId] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.objectId)' in \(student)")
//                    return
//                }
//
//                guard let uniqueKey = student[UdacityClient.JSONResponseKeys.uniqueKey] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.uniqueKey)' in \(student)")
//                    return
//                }
//
//                guard let updatedAt = student[UdacityClient.JSONResponseKeys.updatedAt] as? String else {
//                    print("Cannot find key '\(UdacityClient.JSONResponseKeys.updatedAt)' in \(student)")
//                    return
//                }

