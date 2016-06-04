//
//  STPKTree+CoreDataProperties.swift
//  Street Trees
//
//  Created by Tom Marks on 4/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension STPKTree {

    @NSManaged public  var order: NSNumber?
    @NSManaged public  var latitude: NSNumber?
    @NSManaged public  var longitude: NSNumber?
    @NSManaged public  var speciesName: String?
    @NSManaged public  var savings: NSDecimalNumber?
    @NSManaged public  var kiloWattHours: NSNumber?
    @NSManaged public  var therms: NSNumber?
    @NSManaged public  var stormWater: NSNumber?
    @NSManaged public  var carbon: NSNumber?
    @NSManaged public  var air: NSNumber?
    @NSManaged public  var type: NSNumber?

}
