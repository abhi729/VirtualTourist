//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 22/06/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let apiScheme = "https"
        static let apiHost = "api.flickr.com"
        static let apiPath = "/services/rest"
        static let apiKey = "b3f8a61c65cfac9716d96a8736264654"
        static let safeSearch = 1
        static let extras = "url_m,date_taken"
        static let format = "json"
        static let noJsonCallback = 1
        static let searchBboxHalfWidth:Float = 0.01
        static let searchBboxHalfHeight:Float = 0.01
        static let searchLatRange:(Float, Float) = (-90.0, 90.0)
        static let searchLonRange:(Float, Float) = (-180.0, 180.0)
    }
    
    struct UIConstants {
        static let maxPhotoCount = 21
        static let maxPageCount = 15
        static let maxItemsPerPage = 100
    }
    
    struct Methods {
        static let photoSearch = "flickr.photos.search"
    }
    
    struct ParameterKeys {
        static let bBox = "bbox"
        static let safeSearch = "safe_search"
        static let extras = "extras"
        static let apiKey = "api_key"
        static let method = "method"
        static let format = "format"
        static let noJsonCallback = "nojsoncallback"
        static let perPage = "per_page"
    }
    
}
