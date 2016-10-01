//
//  STFKMapSnapshot.swift
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
import MapKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STFKCameraDistance: CLLocationDistance = 4000.0
private let STFKCameraPitch: CGFloat = 0.0
private let STFKCameraHeading: CLLocationDirection = 0.0
private let STFKSnapshotPointMultiplier: CGFloat = 0.23

//**********************************************************************************************************************
// MARK: - Public Typealias

public typealias STFKMapSnapshotHandler = (image: UIImage?, error: NSError?) -> Void

//**********************************************************************************************************************
// MARK: - Class Implementation

public class STFKMapSnapshot: NSObject {
    
    private let handler: STFKMapSnapshotHandler
    private let location: CLLocation
    
    /// The distance from the ground the snapshot will be taken from. By default it is 4Km
    public var distance = STFKCameraDistance
    
    /// The heading of the map. By default it is `0.0` which is due North
    public var heading = STFKCameraHeading
    
    public var mapType = MKMapType.Standard
    
    /// The viewing angle of the map, measured in degrees. By default the angle is `0.0` which is straight down.
    public var pitch = STFKCameraPitch
    
    /// Should the snapshot include points of interest on the map. By default this is set to `true`.
    public var showPointsOfInterest = true
    
    //******************************************************************************************************************
    // MARK: - Initializers
    
    public init(location aLocation: CLLocation, complete aCompletionHandler: STFKMapSnapshotHandler) {
        self.location = aLocation
        self.handler = aCompletionHandler
        super.init()
    }
    
    //******************************************************************************************************************
    // MARK: - Public Functions
    
    /**
     Begin creating a snapshot with the initialized location.
     */
    public func takeSnapshot() {
        
        let mapOptions = self.mapOptions()
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        
        snapshotter.startWithCompletionHandler { (snapshot: MKMapSnapshot?, error: NSError?) in
            
            guard let image = snapshot?.image else {
                self.handler(image: nil, error: error)
                return
            }
            
            let annotationView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            
            var point = snapshot?.pointForCoordinate(self.location.coordinate) ?? CGPoint.zero
            point.y -= annotationView.frame.size.height
            point.x -= annotationView.frame.size.width * STFKSnapshotPointMultiplier // used to centre the pin
            
            let overlayRect = CGRect(origin: point, size: annotationView.frame.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            
            image.drawAtPoint(CGPoint.zero)
            annotationView.drawViewHierarchyInRect(overlayRect, afterScreenUpdates: true)
            
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            self.handler(image: finalImage, error: error)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    private func mapOptions() -> MKMapSnapshotOptions {
        let mapOptions = MKMapSnapshotOptions()
        let camera = MKMapCamera(lookingAtCenterCoordinate: self.location.coordinate,
                                 fromDistance: self.distance,
                                 pitch: self.pitch,
                                 heading: self.heading)
        mapOptions.camera = camera
        mapOptions.mapType = self.mapType
        mapOptions.scale = UIScreen.mainScreen().scale
        mapOptions.showsPointsOfInterest = self.showPointsOfInterest
        
        return mapOptions
    }
}
