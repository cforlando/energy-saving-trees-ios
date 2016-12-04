//
//  MKPolygonExtension.swift
//  Street Trees
//
//  Created by Tom Marks on 4/12/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import Foundation
import MapKit

public extension MKPolygon {
    
    public func coordinateInsidePolygon(coordinate: CLLocationCoordinate2D) -> Bool {
        
        var inside = false
        
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPointForCoordinate(coordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.pointForMapPoint(currentMapPoint)
        
        if CGPathContainsPoint(polygonRenderer.path, nil, polygonViewPoint, true) {
            inside = true
        }
        
        return inside
    }
}
