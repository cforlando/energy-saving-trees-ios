//
//  tes.swift
//  Street Trees
//
//  Created by Tom Marks on 4/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation

import Alamofire

class tes: NSObject {

    func test() -> Request {
        return Alamofire.request(.GET, "https://www.apple.com")
    }
    
}
