//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Abhishek Agarwal on 08/07/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: NSSet?

}
