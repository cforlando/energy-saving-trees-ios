//
//  TreeLocation.swift
//  Street Trees
//
//  Created by Tommy Lee on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import MapKit

class TreeLocation: NSObject, MKAnnotation {
  var title: String?
  var subtitle: String?
  var latitude: Double
  var longitude: Double
  
  var pinColor: UIColor = MKPinAnnotationView.greenPinColor()

  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  init(name: String, type: String, latitude: Double, longitude: Double) {
    self.title = name
    self.subtitle = type
    self.latitude = latitude
    self.longitude = longitude
    
  }
}