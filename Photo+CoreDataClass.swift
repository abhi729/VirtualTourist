//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 02/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    struct Keys {
        static let imageLocation = "imageLocation"
        static let dateTaken = "dateTaken"
        static let imageURL = "imageUrl"
        static let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        guard let photoEntity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
            fatalError("Could not create Photo Entity Description!")
        }
        
        super.init(entity: photoEntity, insertInto: context)
        
        imageLocation = dictionary[Keys.imageLocation] as? String
        date = dictionary[Keys.dateTaken] as? NSDate
        imageUrl = dictionary[Keys.imageURL] as? String
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

}
