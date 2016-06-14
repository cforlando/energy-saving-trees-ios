//
//  STPKTree.swift
//  Street Trees
//
//  Copyright © 2016 Code for Orlando.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
