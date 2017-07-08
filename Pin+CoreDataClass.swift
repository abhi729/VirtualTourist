//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 02/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {

    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    // MARK: Initializer
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        guard let pinEntity = NSEntityDescription.entity(forEntityName: "Pin", in: context) else {
            fatalError("Could not create Pin Entity Description!")
        }
        
        super.init(entity: pinEntity, insertInto: context)
        
        if let lat = dictionary[Keys.latitude] as? Double, let lon = dictionary[Keys.longitude] as? Double {
            latitude = lat
            longitude = lon
        }
        
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

}
