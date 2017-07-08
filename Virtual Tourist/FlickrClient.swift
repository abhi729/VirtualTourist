//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 22/06/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    override init() {
        super.init()
    }
    
    func checkForErrors(inMethod methodName: String, havingData data: Data?, inResponse response: URLResponse?, havingError error: NSError?) -> NSError?  {
        func sendError(_ error: String) -> NSError {
            let userInfo = [NSLocalizedDescriptionKey : error]
            return NSError(domain: methodName, code: -1, userInfo: userInfo)
        }
        
        /* GUARD: Was there an error? */
        guard error == nil else {
            return sendError("There was an error with your request: \(String(describing: error!.localizedDescription))")
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return sendError("There was an error with your request. Invalid status code sent")
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil else {
            return sendError("No data was returned by the request!")
        }
        
        return nil
    }

    func createBBox(forLatitude latitude:Float, forLongitude longitude:Float) -> String {
        let minLon = max(longitude - Constants.searchBboxHalfWidth, Constants.searchLonRange.0)
        let maxLon = min(longitude + Constants.searchBboxHalfWidth, Constants.searchLonRange.1)
        let minLat = max(latitude - Constants.searchBboxHalfHeight, Constants.searchLatRange.0)
        let maxLat = min(latitude + Constants.searchBboxHalfHeight, Constants.searchLatRange.1)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    func getPhotoPageNumber(withParameters parameters: [String: AnyObject], pin: Pin, completionHandler handler: @escaping (_ page: Int?, _ error: NSError?)-> Void) {
        
        let request = NSMutableURLRequest(url: self.url(fromParameters: parameters))
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = self.checkForErrors(inMethod: "getPhotoPageNumber", havingData: data, inResponse: response, havingError: error as NSError?) {
                handler(nil, error)
            } else if let data = data {
                var parsedResult: AnyObject! = nil
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as json"]
                    handler(nil, NSError(domain: "getPhotoPageNumber", code: -1, userInfo: userInfo))
                }
                if let photos = parsedResult {
                    if let photosDict = photos["photos"] as? [String: AnyObject] {
                        if let pageNumber = photosDict["pages"] as? Int {
                            handler(pageNumber, nil)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    // MARK: Helpers
    
    // Given raw JSON, return a usable Foundation object
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // Create a URL from parameters
    func url(fromParameters parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.apiScheme
        components.host = Constants.apiHost
        components.path = Constants.apiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print(components.url!)
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    var session = URLSession.shared
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}
