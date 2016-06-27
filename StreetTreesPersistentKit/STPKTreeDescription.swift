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
import UIKit


public class STPKTreeDescription: STPKManagedObject {
    
    //******************************************************************************************************************
    // MARK: - Public Class Functions
    
    public class func fetch(descriptionForName name: String, context: NSManagedObjectContext) throws -> STPKTreeDescription? {
        let fetchRequest = NSFetchRequest(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "SELF.name == %@", name)
        fetchRequest.fetchLimit = 1
        
        return try context.executeFetchRequest(fetchRequest).first as? STPKTreeDescription
    }
    
    public class func image(treeName aName: String) -> UIImage? {
        var imageName: String
        switch aName {
        case "Chinese Pistache":
            imageName = "cfo-chinese_pistache"
        case "Crape Myrtle":
            imageName = "cfo-myrtle"
        case "Dahoon Holly":
            imageName = "cfo-dahoon_holly"
        case "Eagleston Holly":
            imageName = "cfo-eagleston_holly"
        case "Japanese Blueberry":
            imageName = "cfo-japanese_blueberry"
        case "Live Oak":
            imageName = "cfo-live_oak"
        case "Nuttall Oak":
            imageName = "cfo-nuttal_oak"
        case "Southern Magnolia":
            imageName = "cfo-magnolia"
        case "Tabebuia Ipe":
            imageName = "cfo-elm" //TODO: Get correct Image
        case "Tuliptree":
            imageName = "cfo-tulip_poplar"
        case "Winged Elm":
            imageName = "cfo-elm"
        case "Yaupon Holly":
            imageName = "cfo-yaupon_holly"
        case "Yellow Tabebuia":
            imageName = "cfo-yellow_trumpet"
        default:
            return nil
        }
        
        let bundle = NSBundle(forClass: self)
        return UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    //******************************************************************************************************************
    // MARK: - Private Class Functions (to the framework)

    override class func entityName() -> String {
        return "STPKTreeDescription"
    }
    
    override public class func insert(context context: NSManagedObjectContext) -> STPKTreeDescription {
        let newTree = STPKTreeDescription(entity: self.entityDescription(inManagedObjectContext: context), insertIntoManagedObjectContext: context)
        return newTree
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public func image() -> UIImage? {
        return STPKTreeDescription.image(treeName: self.name ?? "")
    }
}
