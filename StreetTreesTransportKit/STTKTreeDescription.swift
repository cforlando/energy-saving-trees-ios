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
/*
 {
 "description" : "Highly adaptable to urban soils, the Chinese Pistache's..."
 "full_sun" : "1"
 "leaf" : "Deciduous"
 "max_height_cm" : "10.67"
 "max_width_cm" : "10.67"
 "min_height_cm" : "7.62"
 "min_width_cm" : "7.62"
 "name" : "Chinese Pistache"
 "partial_shade" : "1"
 "partial_sun" : "1"
 "shape" : "Symmetrical"
 "soil" : "clay;sand"
 }
 */

public struct STTKTreeDescription {
    public var additional: String?
    public let description: String
    public let fullSun: Bool
    public let leaf: String
    public let maxHeight: Double
    public let maxWidth: Double
    public let minHeight: Double
    public let minWidth: Double
    public var moisture: String?
    public let name: String
    public let partialShade: Bool
    public let partialSun: Bool
    public let shape: String
    public let soil: String

    init?(json: AnyObject) {
        
        guard let safeJSON = json as? [String: AnyObject] else { return nil }
        
        let additional         = safeJSON["additional"] as? String
        let moisture           = safeJSON["moisture"] as? String
        guard let description  = safeJSON["description"] as? String else {print("failed: description"); return nil;}
        guard let fullSun      = safeJSON["full_sun"] as? String else {print("failed: full_sun"); return nil;}
        guard let leaf         = safeJSON["leaf"] as? String else {print("failed: leaf"); return nil;}
        guard let maxHeight    = safeJSON["max_height_cm"] as? String else {print("failed: max_height_cm"); return nil;}
        guard let maxWidth     = safeJSON["max_width_cm"] as? String else {print("failed: max_width_cm"); return nil;}
        guard let minHeight    = safeJSON["min_height_cm"] as? String else {print("failed: min_height_cm"); return nil;}
        guard let minWidth     = safeJSON["min_width_cm"] as? String else {print("failed: min_width_cm"); return nil;}
        guard let name         = safeJSON["name"] as? String else {print("failed: name"); return nil;}
        guard let partialShade = safeJSON["partial_shade"] as? String else {print("failed: partial_shade"); return nil;}
        guard let partialSun   = safeJSON["partial_sun"] as? String else {print("failed: partial_sun"); return nil;}
        guard let shape        = safeJSON["shape"] as? String else {print("failed: shape"); return nil;}
        guard let soil         = safeJSON["soil"] as? String else {print("failed: soil"); return nil;}
        
        self.additional = additional
        self.description = description
        self.fullSun = Int(fullSun) == 1 ? true : false
        self.leaf = leaf
        self.maxHeight = Double(maxHeight) ?? 0.0
        self.maxWidth =  Double(maxWidth) ?? 0.0
        self.minHeight =  Double(minHeight) ?? 0.0
        self.minWidth =  Double(minWidth) ?? 0.0
        self.moisture =  moisture
        self.name = name
        self.partialShade = Int(partialShade) == 1 ? true : false
        self.partialSun = Int(partialSun) == 1 ? true : false
        self.shape = shape
        self.soil = soil
    
    }
    
}
