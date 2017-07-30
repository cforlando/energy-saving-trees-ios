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

private let STPKRefetchDuration: TimeInterval = 1209600 // 2 weeks

//**********************************************************************************************************************
// MARK: - Typealiases

public typealias STPKFetchCityBoundsHandler = (_ cityBounds: STPKCityBounds?, _ error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

@objc(STPKCityBounds)
open class STPKCityBounds: STPKManagedObject {
    
    //******************************************************************************************************************
    // MARK: - Class overrides
    
    override open class func entityName() -> String {
        return "STPKCityBounds"
    }
    
    override open class func insert(context aContext: NSManagedObjectContext) -> STPKCityBounds {
        let entityDescription = self.entityDescription(inManagedObjectContext: aContext)
        let citybounds = STPKCityBounds(entity: entityDescription, insertInto: aContext)
        return citybounds
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    class func fetch(_ context: NSManagedObjectContext, handler: @escaping STPKFetchCityBoundsHandler) {
    
        guard let citybounds = self.fetchCityBounds(context), let timestamp = citybounds.timestamp else {
            self.downloadCityBounds(context, handler: handler)
            return
        }
        
        let notOutDated = Date().timeIntervalSince(timestamp) < STPKRefetchDuration
        
        if notOutDated {
            handler(citybounds, nil)
        } else {
            self.downloadCityBounds(context, handler: handler)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions

    open func shapes() throws -> [MKPolygon] {
        let json = try JSONSerialization.jsonObject(with: self.json ?? Data(), options: []) as? [AnyHashable: Any]
        let shapes = try GeoJSONSerialization.shapes(fromGeoJSONFeatureCollection: json) as? [MKPolygon]
        return shapes ?? []
    }
    
    //******************************************************************************************************************
    // MARK: - Private Class Functions
    
    fileprivate class func downloadCityBounds(_ fetchContext: NSManagedObjectContext, handler: @escaping STPKFetchCityBoundsHandler) {
        STTKDownloadManager.fetch() { (json: [AnyHashable: Any]) in
            STPKCoreData.sharedInstance.insert(json, completion: { (anError) in
                
                if let safeError = anError {
                    handler(nil, safeError)
                }
                
                if let bounds = self.fetchCityBounds(fetchContext) {
                    handler(bounds, nil)
                } else {
                    let error = NSError(domain: "com.CodeForOrlando.StreeTrees.InsertCityBounds.NewFetch", code: 5, userInfo: nil)
                    handler(nil, error)
                }
            })
        }
    }
    
    fileprivate class func fetchCityBounds(_ context: NSManagedObjectContext) -> STPKCityBounds? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = STPKCityBounds.entityDescription(inManagedObjectContext: context)
        do {
            return try context.fetch(fetchRequest).first as? STPKCityBounds
        } catch {
            return nil
        }
    }
}
