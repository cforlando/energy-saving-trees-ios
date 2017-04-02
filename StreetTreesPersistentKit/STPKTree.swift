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

open class STPKTree: STPKManagedObject {

    //******************************************************************************************************************
    // MARK: - Class overrides
    
    override open class func entityName() -> String {
      return "STPKTree"
    }
    
    override open class func insert(context aContext: NSManagedObjectContext) -> STPKTree {
        let entityDescription = self.entityDescription(inManagedObjectContext: aContext)
        let newTree = STPKTree(entity: entityDescription, insertInto: aContext)
        return newTree
    }
    
    //******************************************************************************************************************
    // MARK: - Class Functions
    
    class func fetch(byOrderNumber anOrderNumber: Int, inContext aContext: NSManagedObjectContext) throws -> STPKTree? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "SELF.order == %@", NSNumber(value: anOrderNumber as Int))
        fetchRequest.fetchLimit = 1
        
        return try aContext.fetch(fetchRequest).first as? STPKTree
    }
}
