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

private let STPKRightOfWayTrees = ["Live Oak",
                                 "Nuttall Oak",
                                 "Magnolia",
                                 "Winged Elm",
                                 "Tabebuia Ipe",
                                 "Eagleston Holly",
                                 "Yaupon Holly",
                                 "Crape Myrtle",
                                 "Yellow Tabebuia",
                                 "Elaeocarpus"]

open class STPKTreeDescription: STPKManagedObject {
    
    //******************************************************************************************************************
    // MARK: - Public Class Functions
    
    override open class func entityName() -> String {
        return "STPKTreeDescription"
    }
    
    open class func fetch(descriptionForName name: String, context: NSManagedObjectContext) throws -> STPKTreeDescription? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName())
        fetchRequest.predicate = NSPredicate(format: "SELF.name == %@", name)
        fetchRequest.fetchLimit = 1
        
        return try context.fetch(fetchRequest).first as? STPKTreeDescription
    }
    
    open class func icon(treeName aName: String) -> UIImage? {
        var imageName: String
        switch aName {
        case "Chinese Pistache":
            imageName = "cfo-chinese_pistache-icon"
        case "Crape Myrtle":
            imageName = "cfo-myrtle-icon"
        case "Dahoon Holly":
            imageName = "cfo-dahoon_holly-icon"
        case "Eagleston Holly":
            imageName = "cfo-eagleston_holly-icon"
        case "Japanese Blueberry":
            imageName = "cfo-japanese_blueberry-icon"
        case "Live Oak":
            imageName = "cfo-live_oak-icon"
        case "Nuttall Oak":
            imageName = "cfo-nuttal_oak-icon"
        case "Southern Magnolia":
            imageName = "cfo-magnolia-icon"
        case "Tabebuia Ipe":
            imageName = "cfo-tabebuia_ipe-icon"
        case "Tulip Poplar":
            imageName = "cfo-tulip_poplar-icon"
        case "Winged Elm":
            imageName = "cfo-elm-icon"
        case "Yaupon Holly":
            imageName = "cfo-yaupon_holly-icon"
        case "Yellow Tabebuia":
            imageName = "cfo-yellow_trumpet-icon"
        default:
            return nil
        }
        
        let bundle = Bundle(for: self)
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
    
    open class func image(treeName aName: String) -> UIImage? {
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
            imageName = "cfo-tabebuia_ipe"
        case "Tulip Poplar":
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
        
        let bundle = Bundle(for: self)
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
    
    override open class func insert(context: NSManagedObjectContext) -> STPKTreeDescription {
        let newTree = STPKTreeDescription(entity: self.entityDescription(inManagedObjectContext: context),
                                          insertInto: context)
        return newTree
    }
    
    open class func rightOfWayTrees() -> [STPKTreeDescription] {
        let allTrees = STPKCoreData.sharedInstance.fetchTreeDescriptions()
        
        return allTrees.filter({
            STPKRightOfWayTrees.contains($0.name ?? "")
        })
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    open func averageWidth() -> Double {
        guard let minimum = self.minWidth?.doubleValue else { return 0.0 }
        guard let maximum = self.maxWidth?.doubleValue else { return 0.0 }
        return (minimum + maximum) / 2
    }
    
    open func icon() -> UIImage? {
        return STPKTreeDescription.icon(treeName: self.name ?? "")
    }
    
    open func image() -> UIImage? {
        return STPKTreeDescription.image(treeName: self.name ?? "")
    }
}
