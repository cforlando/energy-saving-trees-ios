//
//  STFKStreetTreeDateFormatter.swift
//  Street Trees
//
//  Created by Joshua Shroyer on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation

public final class STFKStreetTreeDateFormatter: NSDateFormatter {
    
    public static let sharedInstance = STFKStreetTreeDateFormatter()
    
    override init() {
        super.init()
        locale = NSLocale(localeIdentifier: "en_US_POSIX")
        timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateStyle = .MediumStyle
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}