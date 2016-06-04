//
//  TreeLocation.swift
//  Street Trees
//
//  Created by Tommy Lee on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import MapKit

public class TreeLocation: NSObject, MKAnnotation {
  public var title: String?
  public var subtitle: String?
  public var latitude: Double
  public var longitude: Double
    public let order: Int = 1
  
  public var pinColor: UIColor = MKPinAnnotationView.greenPinColor()

  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
  }
  
  init(name: String, type: String, latitude: Double, longitude: Double) {
    self.title = name
    self.subtitle = type
    self.latitude = latitude
    self.longitude = longitude
    
  }
}