//
//  TreeLocation.swift
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
import FBAnnotationClusteringSwift
import StreetTreesPersistentKit

open class STTreeAnnotation: FBAnnotation {
    open let tree: STPKTree
    open let image: UIImage?
    
    init(tree: STPKTree, image: UIImage?) {
        self.image = image
        self.tree = tree
        super.init()
        self.title = tree.speciesName
        
        let latitude: CLLocationDegrees = tree.latitude?.doubleValue ?? 0.0
        let longitude: CLLocationDegrees = tree.longitude?.doubleValue ?? 0.0
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
}
