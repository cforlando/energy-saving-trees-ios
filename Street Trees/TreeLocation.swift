//
//  TreeLocation.swift
//  Street Trees
//
//  Created by Tommy Lee on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClusteringSwift

public class TreeLocation: FBAnnotation {
  public var subtitle: String?
  public let order: Int = 1
  
  public var pinColor: UIColor = MKPinAnnotationView.greenPinColor()

  
  init(name: String, type: String, latitude: Double, longitude: Double) {
    super.init()
    self.title = name
    self.subtitle = type
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
  }
}