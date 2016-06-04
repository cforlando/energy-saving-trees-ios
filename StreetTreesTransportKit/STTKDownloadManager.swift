//
//  STTKDownloadManager.swift
//  Street Trees
//
//  Created by Joshua Shroyer on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import Alamofire

// App Key from Brigade Open Data Sharing Platform
private let appKey = "aIJDKwhq6DsA4Q5IfBhbAkYHh"

public class STTKDownloadManager {
  
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
    public class func fetchAllTrees(completion: ([STTKStreetTree])->Void ) {
        
        Alamofire.request(.GET, "https://brigades.opendatanetwork.com/resource/7w7p-3857.json",
            parameters: ["$$app_token":appKey])
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
  
}