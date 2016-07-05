//
//  STTKDownloadManager.swift
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

public typealias STTKTreeCompletion = ([STTKStreetTree]) -> Void
public typealias STTKTreeDescriptionCompletion = ([STTKTreeDescription]) -> Void

enum STRequestBuilder: String {
    case Trees = "7w7p-3857.json"
    case TreeDescriptions = "69mx-t3bq.json"
    
    func URLPath() -> String {
        return "https://brigades.opendatanetwork.com/resource/\(self.rawValue)"
    }
}

// App Key from Brigade Open Data Sharing Platform
private let appKey = "aIJDKwhq6DsA4Q5IfBhbAkYHh"

public final class STTKDownloadManager {
    
    //******************************************************************************************************************
    // MARK: - Public Class Functions
    
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
    
    public class func fetch(treeDescriptionsWithcompletion completion: STTKTreeDescriptionCompletion) {
        Alamofire.request(.GET, STRequestBuilder.TreeDescriptions.URLPath(), parameters: self.parameters()).responseJSON {
            response in
            
            if response.result.isSuccess {
                if let JSON = response.result.value as? [AnyObject] {
                    var descriptions = [STTKTreeDescription]()
                    
                    for descriptionJSON in JSON {
                        if let description = STTKTreeDescription(json: descriptionJSON) {
                            descriptions.append(description)
                        }
                    }
                    
                    completion(descriptions)
                    return
                }
            }
            
            completion([STTKTreeDescription]())
        }
    }
    
    // This should probably not be used anymore now that the online API has been updated with location data
    public class func fetch(treesFromLocalFileWithCompletion completion: STTKTreeCompletion) {
        
        // download data on a background queue
        let concurrentQueue = dispatch_queue_create("com.CodeForOrlando.concurrentQueue", DISPATCH_QUEUE_CONCURRENT)
        
        dispatch_async(concurrentQueue) {
            
            if let data = NSData(contentsOfFile: "testData.json") {
                
                // convert data into JSON
                do {
                    if let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [AnyObject] {
                        
                        // Iterate through each of the JSON objects found in the JSON download and load them into a data model array
                        var streetTrees: [STTKStreetTree] = []
                        
                        for treeJSON in JSON {
                            if let tree = STTKStreetTree(json: treeJSON) {
                                streetTrees.append(tree)
                            }
                        }
                        
                        // once done, call the completion handler passing off all the Tree Objects downloaded
                        completion(streetTrees)
                    }
                    completion([STTKStreetTree]())
                } catch {
                    print("NSJSONSerialization Failed with Error: \(error)")
                    completion([STTKStreetTree]())
                }
            } else {
                completion([STTKStreetTree]())
            }
        }
    }
    
    // EXAMPLE JSON OUTPUT
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
    
    // AnyObject? for now, will be changing into a collection of custom tree objects once that data model has been created
    public class func fetch(treesWithCompletion completion: STTKTreeCompletion) {
        
        Alamofire.request(.GET, STRequestBuilder.Trees.URLPath(),
            parameters: self.parameters())
            .responseJSON { response in
                
                //      print(response.request)  // original URL request
                //      print(response.response) // URL response
                //      print(response.data)     // server data
                //      print(response.result)   // result of response serialization
                
                if let JSON = response.result.value as? [AnyObject] {
                    // Iterate through each of the JSON objects found in the JSON download and load them into a data model array
                    var streetTrees: [STTKStreetTree] = []
                    
                    for treeJSON in JSON {
                        if let tree = STTKStreetTree(json: treeJSON) {
                            streetTrees.append(tree)
                        }
                    }
                    
                    // once done, call the completion handler passing off all the Tree Objects downloaded
                    completion(streetTrees)
                } else {
                    completion([STTKStreetTree]())
                }
        }
        
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Class Functions
    
    class internal func parameters() -> [String: String] {
        return ["$$app_token":appKey]
    }
  
}