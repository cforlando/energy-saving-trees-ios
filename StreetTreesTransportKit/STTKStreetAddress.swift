//
//  STTKStreetAddress.swift
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

public struct STTKStreetAddress {
    
    //******************************************************************************************************************
    // MARK: - Public Properties
    
    public let streetAddress: String
    public let secondaryAddress: String
    public let city: String
    public let state: String
    public let zipCode: UInt
    public let country: String
    
    public init(streetAddress: String, secondaryAddress: String, city: String, state: String, zipCode: UInt, country: String) {
        self.streetAddress = streetAddress
        self.secondaryAddress = secondaryAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }

    public func localizedAddress() -> String {
        var address = self.streetAddress
        if !secondaryAddress.isEmpty {
            address += "\n\(self.secondaryAddress)"
        }
        address += "\n\(self.city), \(self.state)"
        address += "\n\(self.country) \(self.zipCode)"
        return address
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    /**
     Converts all of the properties in this struct to be in a format that the Wufoo form expects.
     
     - returns: A `Dictionary<String: String>` with keys that match the Ids for the Wufoo form, and values that are
     the properties of this struct
     */
    func wufooJson() -> [String: String] {
        return ["Field15": self.streetAddress,
                "Field16": self.secondaryAddress,
                "Field17": self.city,
                "Field18": self.state,
                "Field19": "\(self.zipCode)",
                "Field20": self.country]
    }
}
