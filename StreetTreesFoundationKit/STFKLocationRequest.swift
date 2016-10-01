//
//  STFKLocationRequest.swift
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

import CoreLocation
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STFKMaximumLocationStagnationDuration: NSTimeInterval = 30.0 // 😈

//**********************************************************************************************************************
// MARK: - Typealias

public typealias STFKLocationHandler = (location: CLLocation?, error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

public class STFKLocationRequest: NSObject, CLLocationManagerDelegate {
    private let accuracy: CLLocationAccuracy
    private let handler: STFKLocationHandler
    private var manager: CLLocationManager?
    
    public init(accuracy: CLLocationAccuracy, locationHandler: STFKLocationHandler) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
        self.execute()
    }
    
    //******************************************************************************************************************
    // MARK: - CLLocationManager Delegate
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.stopUpdating()
        self.handler(location: nil, error: error)
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last where location.horizontalAccuracy >= self.accuracy else {
            return
        }
        
        if self.isLocationStale(location) {
            return
        }
        
        self.stopUpdating()
        self.handler(location: location, error: nil)
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    public func cancel() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.stopUpdating()
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    private func execute() {
        // All location activity must occur on the main thread
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            self.manager = manager
        }
    }
    
    private func isLocationStale(location: CLLocation) -> Bool {
        return abs(NSDate().timeIntervalSinceDate(location.timestamp)) > STFKMaximumLocationStagnationDuration
    }
    
    private func stopUpdating() {
        self.manager?.stopUpdatingLocation()
        self.manager = nil
    }
}
