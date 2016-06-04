//
//  ViewController.swift
//  Street Trees
//
//  Created by Tom Marks on 3/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import MapKit
import StreetTreesTransportKit
import FBAnnotationClusteringSwift

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    let clusteringManager = FBClusteringManager()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // TODO: Remove this location and call current user location, currently located near code for orlando
        let initialLocation = CLLocation(latitude: 28.5409558, longitude: -81.3834534)
        // Do any additional setup after loading the view, typically from a nib.
        centerMapOnLocation(initialLocation)
        loadPinsToMap()
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
            }
        }
        
    }

    // Change clustering when resizing.
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
      NSOperationQueue().addOperationWithBlock({
        let mapBoundsWidth = Double(self.mapView.bounds.size.width)
        let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
        let scale:Double = mapBoundsWidth / mapRectWidth
        let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
        self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
      })
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      var reuseId = ""
      if annotation.isKindOfClass(FBAnnotationCluster) {
        reuseId = "Cluster"
        var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
        return clusterView
      } else {
        reuseId = "Pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesDrop = true
        pinView?.pinTintColor = UIColor.greenColor()
        return pinView
      }
    }


}
