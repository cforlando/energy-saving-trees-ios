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
 name: String
 description: String
 maxHeight: Double
 minHeight: Double
 maxWidth: Double
 minWidth: Double
 shape: String
 leaf: String
 soil: String
 moisture: String
 fullSun: Bool
 partialShade: Bool
 partialSun: Bool
 additional: String
 }
 */



public struct STTKTreeDescription {
    public let additional: String
    public let description: String
    public let fullSun: Bool
    public let leaf: String
    public let maxHeight: Double
    public let maxWidth: Double
    public let minHeight: Double
    public let minWidth: Double
    public let moisture: String
    public let name: String
    public let partialShade: Bool
    public let partialSun: Bool
    public let shape: String
    public let soil: String

    init?(json: AnyObject) {
        guard let additional = json["additional"] as? String,
        description          = json["description"] as? String,
        fullSun              = json["fullSun"] as? Bool,
        leaf                 = json["leaf"] as? String,
        maxHeight            = json["maxHeight"] as? Double,
        maxWidth             = json["maxWidth"] as? Double,
        minHeight            = json["minHeight"] as? Double,
        minWidth             = json["minWidth"] as? Double,
        moisture             = json["moisture"] as? String,
        name                 = json["name"] as? String,
        partialShade         = json["partialShade"] as? Bool,
        partialSun           = json["partialSun"] as? Bool,
        shape                = json["shape"] as? String,
        soil                 = json["soil"] as? String else {
            return nil
        }
        
        self.additional = additional
        self.description = description
        self.fullSun = fullSun
        self.leaf = leaf
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.minWidth = minWidth
        self.moisture = moisture
        self.name = name
        self.partialShade = partialShade
        self.partialSun = partialSun
        self.shape = shape
        self.soil = soil
    
    }
    
}
