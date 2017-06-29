//
//  STPKUser+CoreDataProperties.swift
//  Street Trees
//
//  Created by Tom Marks on 4/07/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

public extension STPKUser {

    @NSManaged var lastestUpdate: Date?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var streetNumber: NSNumber?
    @NSManaged var streetAddress: String?
    @NSManaged var zipcode: NSNumber?

}
