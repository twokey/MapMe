//
//  UdacityClient.swift
//  MapMe
//
//  Created by Kirill Kudymov on 2017-03-25.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    
    // MARK: Properties
    
    // Shared session
    let session = URLSession.shared
    
    // Shared Instance
    static let sharedInstance = UdacityClient()
    
    // Authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    // MARK: POST
    
    func taskForUdacityPOSTRequest(_ request: NSURLRequest, completionHandlerForRequest: @escaping (_ parsedResult: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 4. Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForRequest(nil, NSError(domain: "taskForUdacityPOSTMethod", code: code, userInfo: userInfo))
            }
            
            // Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)", code: 0)
                return
            }
            
            // Did we get a successful 2xx response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx", code: (response as? HTTPURLResponse)!.statusCode)
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request", code: 1)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)
            let range = Range(5 ..< data.count)
            let newData = data.subdata(in: range)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForRequest)
        }
        
        task.resume()
        
        return task
    }

    
    // MARK: GET
    
    func taskForParseGETRequest(_ request: NSURLRequest, completionHandlerForRequest: @escaping (_ parsedResult: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForRequest(nil, NSError(domain: "taskForParseGETMethod", code: code, userInfo: userInfo))
            }
            
            // Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)", code: 0)
                return
            }
            
            // Did we get a successful 2xx response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx", code: (response as? HTTPURLResponse)!.statusCode)
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request", code: 1)
                return
            }
            
            // Parse the data and use the data (happens in completion handler)

            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForRequest)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
        
    // Given raw JSON, return a suable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result:AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWitCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}
