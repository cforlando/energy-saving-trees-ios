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

extension STPKTree {

    @NSManaged var order: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var speciesName: String?
    @NSManaged var savings: NSDecimalNumber?
    @NSManaged var kiloWattHours: NSNumber?
    @NSManaged var therms: NSNumber?
    @NSManaged var stormWater: NSNumber?
    @NSManaged var carbon: NSNumber?
    @NSManaged var air: NSNumber?
    @NSManaged var type: NSNumber?

}
