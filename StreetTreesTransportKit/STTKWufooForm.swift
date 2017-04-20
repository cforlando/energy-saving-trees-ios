//
//  STTKWufooForm.swift
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

public struct STTKWufooForm {
    
    //******************************************************************************************************************
    // MARK: - Public Properties
    
    public let contact: STTKContact
    
    public var data: Data? {
        return self.query.data(using: .utf8)
    }
    
    public var query: String {
        
        // Create a single string that has all of the fields, and their values.
        let queryItems: String = self.rawContent.reduce("") {
            (result: String, entry: (key: String, value: String)) -> String in
            
            // Create the new entry
            let newEntry = "\(entry.key)=\(entry.value)"
            
            // If this is the first entry, simply return it
            if result == "" {
                return newEntry
            }
            
            // otherwise get the result and add the new entry. The entries follow the same format as a URL query.
            // e.g.: key=value&key2=value2&key3=value3
            return result + "&" + newEntry
        }
        
        return queryItems
    }
    
    public let treeName: String
    
    //******************************************************************************************************************
    // MARK: - Private Properties
    
    fileprivate var rawContent:[String: String] {
        return self.contact.wufooJson() + ["Field6": self.treeName,"Field2": "Right-of-way Trees (individual request)"]
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public init(tree aTreeName: String, forContact aContact: STTKContact) {
        self.contact = aContact
        self.treeName = aTreeName
    }
    
}
