//
//  STPKCityBounds.swift
//  Street Trees
//
//  Created by Tom Marks on 4/12/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
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
    
        guard let citybounds = self.fetchCityBounds(context) else {
            self.downloadCityBounds(context, handler: handler)
            return
        }
        
        let notOutDated = citybounds.timestamp?.timeIntervalSinceNow < STPKRefetchDuration
        
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
