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
    
    //******************************************************************************************************************
    // MARK: - Public Class Functions
    
    public class func snapshot(fromLocation aLocation: CLLocation, snapshotHandler: STFKMapSnapshotHandler) {
        
        let mapOptions = self.mapOptions(forCoordinate: aLocation.coordinate)
        let snapshotter = MKMapSnapshotter(options: mapOptions)
        
        snapshotter.startWithCompletionHandler { (snapshot: MKMapSnapshot?, error: NSError?) in
            
            guard let image = snapshot?.image else {
                snapshotHandler(image: nil, error: error)
                return
            }
            
            let annotationView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            
            var point = snapshot?.pointForCoordinate(aLocation.coordinate) ?? CGPoint.zero
            point.y -= annotationView.frame.size.height
            point.x -= annotationView.frame.size.width * STFKSnapshotPointMultiplier // used to centre the pin
            
            let overlayRect = CGRect(origin: point, size: annotationView.frame.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            
            image.drawAtPoint(CGPoint.zero)
            annotationView.drawViewHierarchyInRect(overlayRect, afterScreenUpdates: true)
            
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            snapshotHandler(image: finalImage, error: error)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Class Functions
    
    private class func mapOptions(forCoordinate aCoordinate: CLLocationCoordinate2D) -> MKMapSnapshotOptions {
        let mapOptions = MKMapSnapshotOptions()
        let camera = MKMapCamera(lookingAtCenterCoordinate: aCoordinate,
                                 fromDistance: STFKCameraDistance,
                                 pitch: STFKCameraPitch,
                                 heading: STFKCameraHeading)
        mapOptions.camera = camera
        mapOptions.mapType = .Standard
        mapOptions.scale = UIScreen.mainScreen().scale
        mapOptions.showsPointsOfInterest = true
        
        return mapOptions
    }
}
