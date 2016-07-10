//
//  STPKManagedObject.swift
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

import CoreData
import Foundation

public class STPKManagedObject: NSManagedObject {
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public class func entityName() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    public class func fetch(context: NSManagedObjectContext) throws -> [STPKManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        return try context.executeFetchRequest(fetchRequest) as? [STPKManagedObject] ?? []
    }
    
    public class func insert(context context: NSManagedObjectContext) -> STPKManagedObject {
        preconditionFailure("This method must be overridden")
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions (to the framework)
    
    class func entityDescription(inManagedObjectContext context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)!
    }
}