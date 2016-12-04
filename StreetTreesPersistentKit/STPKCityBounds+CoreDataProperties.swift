//
//  STPKCityBounds+CoreDataProperties.swift
//  Street Trees
//
//  Created by Tom Marks on 4/12/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension STPKCityBounds {

    @NSManaged var json: NSData?
    @NSManaged var timestamp: NSDate?

}
