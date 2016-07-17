//
//  STWufooRequest.swift
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

import Alamofire
import Foundation
import StreetTreesFoundationKit
import StreetTreesPersistentKit

//**********************************************************************************************************************
// MARK: - Private Constants

private let STTKAPIKey = "APIKeyHere:password" //TODO: update with correct API Key
private let STTKBaseURLPath = "https://cityoforlando.wufoo.com/api/v3/forms/{identifier}/entries.json"
private let STTKStreetTreeFormIdentifier = "tree-planting-program-online-application"
private let STTKRequestTimeout: NSTimeInterval = 10.0

//**********************************************************************************************************************
// MARK: - Public Typealiases
public typealias STTKRequestComplete = (error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

/// STTKWufooRequest is a concrete Post request
public class STTKWufooRequest: NSMutableURLRequest {
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public init() {
        let URLPath = STTKBaseURLPath.stringByReplacingOccurrencesOfString("{identifier}",
                                                                           withString: STTKStreetTreeFormIdentifier)
        let URL = NSURL(string: URLPath)!
        
        super.init(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: STTKRequestTimeout)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    func commonInit() {
        guard let apiKey = STTKAPIKey.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions([]) else {
            return
        }
        
        self.HTTPMethod = "Post"
        self.addValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
    }
    
}

extension STTKWufooRequest {
    
    /**
     Performs the request using all of the information that was given at initialization and passed via this function
     call. The request will add the form data to the correct entries on the Wufoo form.
     
     - parameter form:       The `STTKWufooForm` that is being submitted by the user.
     - parameter completion: The completion block that will be called once the request has either recieved a response 
                             from the server, or timed out.
     */
    public func execute(form: STTKWufooForm, completion: STTKRequestComplete) {
        self.HTTPBody = form.data
        
        print("------------- Request Start --------------")
        print("URL: \(self.URL)")
        print("Content: \(form.query)")
        print("-------------- Request End ---------------")

        Alamofire.request(self).responseJSON { (response: Response<AnyObject, NSError>) in
            print("------------- Response Start --------------")
            print("Status Code: \(response.response?.statusCode)")
            print("Header Fields: \(response.response?.allHeaderFields)")
            print("Full Response: \(response.result.value)")
            print("Error: \(response.result.error)")
            print("-------------- Response End ---------------")
            
            completion(error: response.result.error)
        }
    }
}
