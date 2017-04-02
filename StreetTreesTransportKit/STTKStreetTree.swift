//
//  STTKStreetTree.swift
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
    public let date: Date
    public let kWh: Double
    public let lat: Double
    public let long: Double
    public let name: String
    public let order: Int
    public let savings: Double
    public let stormwater: Double
    public let therms: Double
   
    
    init?(json: AnyObject) {
        
        // Make sure the json object passed to this initializer
        //has all the properties needed else return nil
        guard let airString = json["air"] as? String,
                let carbonString = json["carbon"] as? String,
            let kWhString = json["kwh"] as? String,
            let orderString = json["order"] as? String,
            let savingsString = json["savings"] as? String,
            let stormwaterString = json["stormwater"] as? String,
            let thermsString = json["therms"] as? String,
            let name = json["tree_name"] as? String,
            let dateString = json["date"] as? String,
            let location = json["location"] as? [AnyHashable: Any],
            let coordinates = location["coordinates"] as? [AnyObject],
            let long = coordinates[0] as? Double,
            let lat = coordinates[1] as? Double else {
                // Did not meet the required fields
                return nil
        }
        
        
        
        // Make sure the strings loaded convert properly
        guard let air = Double(airString), let carbon = Double(carbonString),
            let kWh = Double(kWhString), let order = Int(orderString),
            let savings = Double(savingsString), let stormwater = Double(stormwaterString),
            let therms = Double(thermsString), let date = STFKStreetTreeDateFormatter.sharedInstance.date(from: dateString) else {
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
        self.long = long
        self.lat = lat
        
        // All names need to be sanitised because they usually contain additional white space
        var trimmedName = name.trimmingCharacters(in: CharacterSet.whitespaces)
        
        // The Tulip Poplar tree is incorrectly named in the DB. This is a fix until the DB can be updated.
        if trimmedName == "Tuliptree" {
            trimmedName = "Tulip Poplar"
        }
        
        self.name = trimmedName
    }
}
