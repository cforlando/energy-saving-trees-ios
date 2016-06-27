//
//  STTreeDetailsTableViewController.swift
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
import StreetTreesPersistentKit

private let STGoldenRatio: CGFloat = 0.618
private let STRegionOffset: CLLocationDegrees = 0.0004
private let STRegionRadius: CLLocationDistance = 0.001
private let STEstimateRowHeight: CGFloat = 44.0

enum STDetailRows {
    case Age
    case Details
    case Directions
    case Email
    case LifeExpectency
    case Height
    
}

class STTreeDetailsTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: STTreeAnnotation?
    
    let datasource: [[STDetailRows]] = [[.Directions],
                                        [.Details, .Email, .LifeExpectency, .Height]]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.annotation?.tree.speciesName
        self.tableView.estimatedRowHeight = STEstimateRowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.setupMapView()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = abs(scrollView.contentOffset.y + scrollView.contentInset.top)
        self.containerView.clipsToBounds = offsetY <= 0
        
        self.bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let contentMinimumHeight = screenHeight - (screenHeight * STGoldenRatio)
        let contentInset = scrollView.contentInset.top + contentMinimumHeight
        self.heightLayoutConstraint.constant = max(offsetY + contentInset, scrollView.contentInset.top)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.updateMapRegion()
    }
    
    //******************************************************************************************************************
    // MARK: - MapView Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "TreePin"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        
        annotationView?.canShowCallout = false
        
        if let treeLocation = annotation as? STTreeAnnotation {
            annotationView?.image = treeLocation.image
        }
        
        return annotationView
    }
    
    //******************************************************************************************************************
    // MARK: - TableView Datasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.datasource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let basicCell = tableView.dequeueReusableCellWithIdentifier("basic", forIndexPath: indexPath)
        
        let section = self.datasource[indexPath.section]
        let row = section[indexPath.row]
        let content: String
        let treeDescription = self.annotation?.tree.treeDescription
        
        switch row {
        case .Age:
            content = "1000" // Use treeDescription to get the current age and the sown/order date.
        case .Details:
            content = treeDescription?.treeDescription ?? "Tree Description Tree Description Tree Description Tree Description Tree DescriptionTree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description Tree Description"
        case .Email:
            content = "tree@orlando.com"
        case .Height:
            content = "100m" // Use treeDescription to get the min & max height
        case .LifeExpectency:
            content = "10 yrs" // Use treeDescription to get the min & max age
        case .Directions:
            content = "Open in Maps"
        }
        
        basicCell.textLabel?.text = content
        
        return basicCell
    }
    
    //******************************************************************************************************************
    // MARK: - TableView Delegate
    
    // TODO: Add link to open maps app to get a route to the trees location.
    
    //******************************************************************************************************************
    // MARK: - Functions
    
    func setupMapView() {
        
        self.updateMapRegion()
        
        // Add annotation to map
        if let annotation = self.annotation {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func updateMapRegion() {
        // Set up map position
        var latitude: CLLocationDegrees = self.annotation?.tree.latitude?.doubleValue ?? 0.0
        let longitude: CLLocationDegrees = self.annotation?.tree.longitude?.doubleValue ?? 0.0
        
        latitude += self.traitCollection.verticalSizeClass == .Compact ? 0.0 : STRegionOffset
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mapView.setCenterCoordinate(coordinate, animated: false)
        
        // Set region
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: STRegionRadius, longitudeDelta: STRegionRadius)
        let region = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
        self.mapView.setRegion(region, animated: true)
    }

}
