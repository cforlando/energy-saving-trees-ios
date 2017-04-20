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

private let STFKMaximumLocationStagnationDuration: TimeInterval = 30.0 // 😈

//**********************************************************************************************************************
// MARK: - Typealias

public typealias STFKLocationHandler = (_ location: CLLocation?, _ error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

open class STFKLocationRequest: NSObject, CLLocationManagerDelegate {
    fileprivate let accuracy: CLLocationAccuracy
    fileprivate let handler: STFKLocationHandler
    fileprivate var manager: CLLocationManager?
    
    public init(accuracy: CLLocationAccuracy, locationHandler: @escaping STFKLocationHandler) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
        self.execute()
    }
    
    //******************************************************************************************************************
    // MARK: - CLLocationManager Delegate
    
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.stopUpdating()
        self.handler(nil, error as NSError)
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= self.accuracy else {
            return
        }
        
        if self.isLocationStale(location) {
            return
        }
        
        self.stopUpdating()
        self.handler(location, nil)
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    open func cancel() {
        DispatchQueue.main.async { [unowned self] in
            self.stopUpdating()
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    fileprivate func execute() {
        // All location activity must occur on the main thread
        DispatchQueue.main.async { [unowned self] in
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            self.manager = manager
        }
    }
    
    fileprivate func isLocationStale(_ location: CLLocation) -> Bool {
        return abs(Date().timeIntervalSince(location.timestamp)) > STFKMaximumLocationStagnationDuration
    }
    
    fileprivate func stopUpdating() {
        self.manager?.stopUpdatingLocation()
        self.manager = nil
    }
}
