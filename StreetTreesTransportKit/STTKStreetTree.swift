//
//  STTKStreetTree.swift
//  Street Trees
//
//  Created by Joshua Shroyer on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import StreetTreesFoundationKit

// EXAMPLE JSON OUTPUT
// Location currently missing. Should be fixed soon *fingers crossed*
/*
 {
 "Order #": "76065",
 "Date": "11/13/2015 18:24",
 "Location": "28.562917, -81.350608",
 "Tree name": "Nuttall Oak",
 "Savings": "37.57",
 "kWh": "314.5",
 "Therms": "0.6",
 "Stormwater": "10149.10545",
 "Carbon": "2046.578665",
 "Air": "3.7045"
 }
 */



public struct STTKStreetTree {
    public let air: Double
    public let carbon: Double
    public let date: NSDate
    public let kWh: Double
    public let order: Int
    public let savings: Double
    public let stormwater: Double
    public let therms: Double
    public let name: String
    public let long: Double
    public let lat: Double
   
    
    init?(json: AnyObject) {
        
        // Make sure the json object passed to this initializer
        //has all the properties needed else return nil
        guard let airString = json["air"] as? String, carbonString = json["carbon"] as? String,
            kWhString = json["kwh"] as? String, orderString = json["order"] as? String,
            savingsString = json["savings"] as? String, stormwaterString = json["stormwater"] as? String,
            thermsString = json["therms"] as? String, name = json["tree_name"] as? String,
            dateString = json["date"] as? String, location = json["location"] as? [NSObject: AnyObject],
            coordinates = location["coordinates"] as? [AnyObject], long = coordinates[0] as? Double,
            lat = coordinates[1] as? Double else {
                // Did not meet the required fields
                return nil
        }
        
        
        
        // Make sure the strings loaded convert properly
        guard let air = Double(airString), carbon = Double(carbonString),
            kWh = Double(kWhString), order = Int(orderString),
            savings = Double(savingsString), stormwater = Double(stormwaterString),
            therms = Double(thermsString), date =  STFKStreetTreeDateFormatter.sharedInstance.dateFromString(dateString) else {
                // While we loaded the correct fields, the values did not convert properly
                return nil
        }
        
        self.air = air
        self.carbon = carbon
        self.date = date
        self.kWh = kWh
        self.order = order
        self.savings = savings
        self.stormwater = stormwater
        self.therms = therms
        self.name = name
        self.long = long
        self.lat = lat
    }
}