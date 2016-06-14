//
//  ViewController.swift
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

import UIKit
import MapKit
import StreetTreesTransportKit
import FBAnnotationClusteringSwift
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var foundUser = false
    let clusteringManager = FBClusteringManager()
    let locationManager = CLLocationManager()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // TODO: Remove this location and call current user location, currently located near code for orlando
        
        loadPinsToMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.locationManager.delegate = self
        self.setupLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func centerMapOnLocation(location: CLLocation) {
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                regionRadius * 2.0, regionRadius * 2.0)
      mapView.setRegion(coordinateRegion, animated: true)
    }
  
    func loadPinsToMap() {
        
        STTKDownloadManager.fetchAllTrees { (treeData:[STTKStreetTree]) in
            STCoreData.sharedInstance.insertNewTrees(treeData) { (anError: NSError?) -> Void in
                if anError != nil {
                    //TODO: throw error?
                    return
                }
                var clusters:[FBAnnotation] = []
                for tree in STCoreData.sharedInstance.fetchTrees() {
                    let pin = TreeLocation(name: tree.speciesName ?? "", type: "Tuliptree", latitude: tree.latitude?.doubleValue ?? 0.0, longitude: tree.longitude?.doubleValue ?? 0.0)
                    
                    self.mapView.addAnnotation(pin)
                    clusters.append(pin)
                }
                self.clusteringManager.addAnnotations(clusters)
                self.loadPins()
            }
        }
        
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.loadPins()
    }
    
    func loadPins() {
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var reuseId = ""
        if annotation.isKindOfClass(FBAnnotationCluster) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        } else {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.image = UIImage(named: "tree")
//            pinView?.pinTintColor = UIColor.greenColor()
            return pinView
        }
    }

    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !self.foundUser {
            self.foundUser = true
            self.centerMapOnLocation(userLocation.location!)
        }
    }
    
    func setupLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined, .Restricted:
            self.locationManager.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            self.mapView.showsUserLocation = true
        default:
            ()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            self.mapView.showsUserLocation = true
        }
    }
}
