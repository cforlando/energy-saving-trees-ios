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

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
  
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
                for tree in STCoreData.sharedInstance.fetchTrees() {
                    let pin = TreeLocation(name: tree.speciesName ?? "", type: "Tuliptree", latitude: tree.latitude?.doubleValue ?? 0.0, longitude: tree.longitude?.doubleValue ?? 0.0)
                    self.mapView.addAnnotation(pin)
                }
            }
        }
        
    }
  
    func mapView(mapView: MKMapView,
                            viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      
      let reuseId = "pin"
      var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
      if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesDrop = true
        pinView?.pinTintColor = UIColor.greenColor()
      } else {
        pinView?.annotation = annotation
      }
      return pinView
      
    }
}
