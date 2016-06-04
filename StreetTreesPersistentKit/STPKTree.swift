//
//  STPKTree.swift
//  Street Trees
//
//  Created by Tom Marks on 4/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import CoreData


public class STPKTree: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    class func entityName() -> String {
      return "STPKTree"
    }
    
    class func entityDescription(inManagedObjectContext context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)!
    }
    
    class func tree(withJSON json:[String: AnyObject], inContext context: NSManagedObjectContext) -> STPKTree? {
        return nil
    }
    
}
