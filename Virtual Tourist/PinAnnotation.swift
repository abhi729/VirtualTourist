//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 02/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import MapKit

class PinAnnotation: MKPointAnnotation {
    var pin:Pin?
    
    override init() {
        super.init()
    }
    
    init(withManagedPin pin:Pin) {
        super.init()
        
        self.pin = pin
    }
}
