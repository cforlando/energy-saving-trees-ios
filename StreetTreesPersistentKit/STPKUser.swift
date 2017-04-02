//
//  STPKUser.swift
//  Street Trees
//
//  Created by Tom Marks on 4/07/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import CoreData


open class STPKUser: STPKManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    //******************************************************************************************************************
    // MARK: - Class overrides
    
    override open class func entityName() -> String {
        return "STPKUser"
    }

    override open class func insert(context aContext: NSManagedObjectContext) -> STPKUser {
        let entityDescription = self.entityDescription(inManagedObjectContext: aContext)
        let newUser = STPKUser(entity: entityDescription, insertInto: aContext)
        return newUser
    }

}
