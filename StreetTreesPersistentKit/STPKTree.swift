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
    
    public class func insertTree(context context: NSManagedObjectContext) -> STPKTree {
        let newTree = STPKTree(entity: self.entityDescription(inManagedObjectContext: context), insertIntoManagedObjectContext: context)
        return newTree
    }
    
    public class func fetchTrees(context: NSManagedObjectContext) throws -> [STPKTree] {
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        return try context.executeFetchRequest(fetchRequest) as? [STPKTree] ?? []
    }
    
}
