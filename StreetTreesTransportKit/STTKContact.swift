//
//  STTKContact.swift
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

public struct STTKContact {
    
    //******************************************************************************************************************
    // MARK: - Public Properties
    
    public let address: STTKStreetAddress
    public let email: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: UInt
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    /**
     Converts all of the properties in this struct to be in a format that the Wufoo form expects.
     
     - returns: A `Dictionary<String: String>` with keys that match the Ids for the Wufoo form, and values that are
                the properties of this struct
     */
    func wufooJson() -> [String: String] {
        
        let contactJSON = ["Field8": "\(self.firstName) \(self.lastName)",
                           "Field21": "\(self.phoneNumber)",
                           "Field22": self.email]
        
        let addressJSON = self.address.wufooJson()
        
        return contactJSON + addressJSON
    }
}
