//
//  ViewController.swift
//  Street Trees
//
//  Created by Tom Marks on 3/06/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import MapKit

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
  
    func getTestPins() -> [TreeLocation] {
      var listOfTrees = [TreeLocation]()
      // TODO: Remove this and make this a call to an API Instead
      listOfTrees.append(TreeLocation(name: "Code For Orlando Root Tree", type: "Tuliptree", latitude: 28.5409558, longitude: -81.3834533))
      listOfTrees.append(TreeLocation(name: "Amway Tree", type: "Tuliptree", latitude: 28.5402526, longitude: -81.3838138))
      listOfTrees.append(TreeLocation(name: "Tree 3", type: "Nuttall Oak", latitude: 28.561112, longitude: -81.314404))
      listOfTrees.append(TreeLocation(name: "Tree 4", type: "Dahoon Holly ", latitude: 28.572687, longitude: -81.354554))
      listOfTrees.append(TreeLocation(name: "Tree 5", type: "Nuttall Oak", latitude: 28.595769, longitude: -81.447467))
      listOfTrees.append(TreeLocation(name: "Tree 6", type: "Dahoon Holly ", latitude: 28.520755, longitude: -81.504856))
      listOfTrees.append(TreeLocation(name: "Tree 7", type: "Tuliptree", latitude: 28.482421, longitude: -81.306295))
      listOfTrees.append(TreeLocation(name: "Tree 8", type: "Chinese Pistache ", latitude: 28.529737, longitude: -81.496019))
      listOfTrees.append(TreeLocation(name: "Tree 9", type: "Chinese Pistache ", latitude: 28.482740, longitude: -81.330051))
      listOfTrees.append(TreeLocation(name: "Tree 10", type: "Tuliptree", latitude: 28.524291, longitude: -81.370373))
      
      return listOfTrees
    }

  
  
    func loadPinsToMap() {
      let pins = getTestPins()
      for pin in pins {
        mapView.addAnnotation(pin)
      }
    }
  
    func mapView(mapView: MKMapView,
                            viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      
      let reuseId = "pin"
      var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
      if pinView == nil {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.animatesDrop = true
        pinView!.pinTintColor = UIColor.greenColor()
      } else {
        pinView!.annotation = annotation
      }
      return pinView
      
    }
}
