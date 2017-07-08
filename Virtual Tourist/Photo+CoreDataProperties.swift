//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 15/06/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var imageLocation: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
