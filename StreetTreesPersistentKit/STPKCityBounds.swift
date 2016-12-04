//
//  STPKCityBounds.swift
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
import GeoJSONSerialization
import MapKit
import StreetTreesTransportKit

//**********************************************************************************************************************
// MARK: - Constants

private let STPKRefetchDuration: NSTimeInterval = 1209600 // 2 weeks

//**********************************************************************************************************************
// MARK: - Typealiases

public typealias STPKFetchCityBoundsHandler = (cityBounds: STPKCityBounds?, error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

@objc(STPKCityBounds)
public class STPKCityBounds: STPKManagedObject {
    
    //******************************************************************************************************************
    // MARK: - Class overrides
    
    override public class func entityName() -> String {
        return "STPKCityBounds"
    }
    
    override public class func insert(context aContext: NSManagedObjectContext) -> STPKCityBounds {
        let entityDescription = self.entityDescription(inManagedObjectContext: aContext)
        let citybounds = STPKCityBounds(entity: entityDescription, insertIntoManagedObjectContext: aContext)
        return citybounds
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    class func fetch(context: NSManagedObjectContext, handler: STPKFetchCityBoundsHandler) {
    
        guard let citybounds = self.fetchCityBounds(context), let timestamp = citybounds.timestamp else {
            self.downloadCityBounds(context, handler: handler)
            return
        }
        
        let notOutDated = NSDate().timeIntervalSinceDate(timestamp) < STPKRefetchDuration
        
        if notOutDated {
            handler(cityBounds: citybounds, error: nil)
        } else {
            self.downloadCityBounds(context, handler: handler)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions

    public func shapes() throws -> [MKPolygon] {
        let json = try NSJSONSerialization.JSONObjectWithData(self.json ?? NSData(), options: []) as? [NSObject: AnyObject]
        let shapes = try GeoJSONSerialization.shapesFromGeoJSONFeatureCollection(json) as? [MKPolygon]
        return shapes ?? []
    }
    
    //******************************************************************************************************************
    // MARK: - Private Class Functions
    
    private class func downloadCityBounds(fetchContext: NSManagedObjectContext, handler: STPKFetchCityBoundsHandler) {
        STTKDownloadManager.fetch() { (json: [NSObject:AnyObject]) in
            STPKCoreData.sharedInstance.insert(json, completion: { (anError) in
                
                if let safeError = anError {
                    handler(cityBounds: nil, error: safeError)
                }
                
                if let bounds = self.fetchCityBounds(fetchContext) {
                    handler(cityBounds: bounds, error: nil)
                } else {
                    let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds.NewFetch", code: 5, userInfo: nil)
                    handler(cityBounds: nil, error: error)
                }
            })
        }
    }
    
    private class func fetchCityBounds(context: NSManagedObjectContext) -> STPKCityBounds? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = STPKCityBounds.entityDescription(inManagedObjectContext: context)
        do {
            return try context.executeFetchRequest(fetchRequest).first as? STPKCityBounds
        } catch {
            return nil
        }
    }
}
