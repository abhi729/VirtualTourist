//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 22/06/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPhotosByLocation(forPin pin: Pin, completionHandler handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parameters = [String: AnyObject]()
        parameters[ParameterKeys.bBox] = createBBox(forLatitude: Float(pin.latitude), forLongitude: Float(pin.longitude)) as AnyObject
        parameters["safe_search"] = Constants.safeSearch as AnyObject
        parameters["extras"] = Constants.extras as AnyObject
        parameters["api_key"] = Constants.apiKey as AnyObject
        parameters["method"] = Methods.photoSearch as AnyObject
        parameters["format"] = Constants.format as AnyObject
        parameters["nojsoncallback"] = Constants.noJsonCallback as AnyObject
        parameters["per_page"] = UIConstants.maxPhotoCount as AnyObject
        
        getPhotoPageNumber(withParameters: parameters, pin: pin) { (page, error) -> Void in
            guard error == nil else {
                handler(nil, error)
                return
            }
            
            if let pageCount = page {
                let pageLimit = min(pageCount, UIConstants.maxItemsPerPage)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                parameters["page"] = min(randomPage, UIConstants.maxPageCount) as AnyObject
                
                let request = NSMutableURLRequest(url: self.url(fromParameters: parameters))
                
                let task = self.session.dataTask(with: request as URLRequest) { (data, response, error) in
                    if let error = self.checkForErrors(inMethod: "getPhotosByLocation", havingData: data, inResponse: response, havingError: error as NSError?) {
                        handler(nil, error)
                    } else if let data = data {
                        self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: handler)
                    }
                }
                task.resume()
            }
        }
    }
}
