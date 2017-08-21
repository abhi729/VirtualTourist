//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 21/08/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?

}
