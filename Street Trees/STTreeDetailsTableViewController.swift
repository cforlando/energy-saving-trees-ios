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

import MapKit
import StreetTreesPersistentKit
import StreetTreesFoundationKit
import UIKit

private let STEstimateRowHeight: CGFloat = 44.0
private let STGoldenRatio: CGFloat = 0.618
private let STRegionOffset: CLLocationDegrees = 0.0004
private let STRegionRadius: CLLocationDistance = 0.001
private let STDefaultOffset: CGFloat = -64.0

enum STDetailRows {
    case Additional
    case Description
    case Height
    case Leaf
    case Moisture
    case Name
    case OpenInMaps
    case Shape
    case Soil
    case Width
    case Birthday
    
    func sectionHeader() -> String? {
        switch self {
        case .Additional:
            return "Additional"
        case .OpenInMaps, .Birthday:
            return nil
        case .Name, .Description:
            return nil
        case .Width, .Height, .Shape:
            return "Dimensions"
        case .Soil, .Moisture, .Leaf:
            return "Foilage and Environment"
        }
    }
}

class STTreeDetailsTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: STTreeAnnotation?
    var treeDescription: STPKTreeDescription? {
        return self.annotation?.tree.treeDescription
    }
    
    lazy var datasource: [[STDetailRows]] = {
    
        var source: [[STDetailRows]] = [[.Name, .Description, .Birthday],
                                        [.OpenInMaps],
                                        [.Height, .Width, .Shape]]
        
        var foilageAndEnvironment: [STDetailRows] = [.Leaf, .Soil]
        if self.treeDescription?.moisture != nil {
            foilageAndEnvironment.append(.Moisture)
        }
        
        source.append(foilageAndEnvironment)
        
        if self.treeDescription?.additional != nil {
            source.append([.Additional])
        }
        
        return source
    
    }()
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.annotation?.tree.speciesName
        self.tableView.estimatedRowHeight = STEstimateRowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.clearsSelectionOnViewWillAppear = true
        self.setupMapView()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {        
        if scrollView.contentOffset.y > STDefaultOffset {
            return
        }
        
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
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleView = MKCircleRenderer(circle: circleOverlay)
            circleView.lineWidth = 3.0
            circleView.strokeColor = UIColor.orlandoGreenColor()
            circleView.fillColor = UIColor.orlandoGreenColor(0.2)
            return circleView
        }
        
        return MKOverlayRenderer()
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
        
        let row = self.detailRow(forIndexPath: indexPath)
        let content: String
        var subtitle: String? = nil
        basicCell.selectionStyle = .None
        
        switch row {
        case .Name:
            content = self.treeDescription?.name ?? "Error retrieving name"
        case .Description:
            content = self.treeDescription?.treeDescription ?? "Tree Description Missing"
        case .Height:
            let height = self.localizedHeight()
            content = height.content
            subtitle = height.subtitle
        case .Width:
            let height = self.localizedWidth()
            content = height.content
            subtitle = height.subtitle
        case .OpenInMaps:
            content = "Open in Maps"
        case .Leaf:
            content = self.treeDescription?.leaf ?? "Leaf information missing"
            subtitle = "Leaf"
        case .Shape:
            content = self.treeDescription?.shape ?? "Shape information missing"
            subtitle = "Shape"
        case .Soil:
            let soil = self.treeDescription?.soil
            content = soil?.stringByReplacingOccurrencesOfString(";", withString: ", ") ?? "Soil information missing"
            subtitle = "Soil"
        case .Moisture:
            content = self.treeDescription?.moisture ?? "Moisture information missing"
            subtitle = "Moisture"
        case .Additional:
            content = self.treeDescription?.additional ?? "Additional information missing"
        case .Birthday:
            if let date = self.annotation?.tree.date {
                let dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
                content = dateString
            } else {
                content = "No Date Available"
            }
        }
        
        basicCell.textLabel?.text = content
        basicCell.detailTextLabel?.text = subtitle
        
        return basicCell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rows = self.datasource[section]
        return rows.first?.sectionHeader()
    }
    
    //******************************************************************************************************************
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let detail = self.detailRow(forIndexPath: indexPath)
        
        return detail == .OpenInMaps ? indexPath : nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailRow = self.detailRow(forIndexPath: indexPath)
        
        if detailRow == .OpenInMaps {
            self.openInMaps()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Functions
    
    func detailRow(forIndexPath anIndexPath: NSIndexPath) -> STDetailRows {
        let section = self.datasource[anIndexPath.section]
        return section[anIndexPath.row]
    }
    
    func localizedHeight() -> (subtitle: String, content: String) {
        guard let minimum = self.annotation?.tree.treeDescription?.minHeight?.doubleValue else {
            return (subtitle:"Error", content: "Getting minimum height")
        }
        guard let maximum = self.annotation?.tree.treeDescription?.maxHeight?.doubleValue else {
            return (subtitle:"Error", content: "Getting maximum height")
        }
        
        return (subtitle:"Average Height", content: self.localizedLength(minimum, maximum: maximum, unitType: .Meter))
    }
    
    func localizedLength(minimum: Double, maximum: Double, unitType aType: NSLengthFormatterUnit) -> String {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Medium
        
        let minimumString = formatter.stringFromValue(minimum, unit: aType)
        let maximumString = formatter.stringFromValue(maximum, unit: aType)
        
        return "\(minimumString) - \(maximumString)"
    }
    
    func localizedWidth() -> (subtitle: String, content: String) {
        guard let minimum = self.annotation?.tree.treeDescription?.minHeight?.doubleValue else {
            return (subtitle:"Error", content: "Getting minimum width")
        }
        guard let maximum = self.annotation?.tree.treeDescription?.maxHeight?.doubleValue else {
            return (subtitle:"Error", content: "Getting maximum weight")
        }
        
        return (subtitle:"Average Weight", content: self.localizedLength(minimum, maximum: maximum, unitType: .Meter))
    }
    
    func openInMaps() {
        if let latitude = self.annotation?.tree.latitude as? CLLocationDegrees,
            let longitude = self.annotation?.tree.longitude as? CLLocationDegrees,
            let URL = NSURL(string: "http://maps.apple.com/maps?q=\(latitude),\(longitude)"){
            
            if UIApplication.sharedApplication().canOpenURL(URL) {
                UIApplication.sharedApplication().openURL(URL)
            } else {
                self.showAlert("Oops", message: "Street Trees was unable to open maps.")
            }
        } else {
            self.showAlert("Oops", message: "Something went wrong getting the location of the tree.")
        }
    }
    
    func setupMapView() {
        
        self.updateMapRegion()
        
        // Add annotation to map
        if let annotation = self.annotation {
            let distance: CLLocationDistance = self.treeDescription?.averageWidth() ?? 0.0
            let circleOverlay = MKCircle(centerCoordinate: annotation.coordinate, radius: distance)
            self.mapView.addAnnotation(annotation)
            self.mapView.addOverlay(circleOverlay)
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
