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
import StreetTreesFoundationKit
import StreetTreesPersistentKit
import UIKit

private let STCellAccessorySize = CGSize(width: 40, height: 40)
private let STDefaultOffset: CGFloat = -64.0
private let STDefaultTableViewHeaderHeight: CGFloat = 150.0
private let STEstimateRowHeight: CGFloat = 44.0
private let STGoldenRatio: CGFloat = 0.618
private let STRegionOffset: CLLocationDegrees = 0.0004
private let STRegionRadius: CLLocationDistance = 0.001
private let STSnapshotDistance: CLLocationDistance = 500.0

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

class STTreeDetailsTableViewController: UITableViewController {

    @IBOutlet weak var mapImageView: UIImageView!
    
    var headerView: UIView?
    
    var annotation: STTreeAnnotation?
    var treeDescription: STPKTreeDescription? {
        return self.annotation?.tree.treeDescription
    }
    
    lazy var datasource: [[STDetailRows]] = {
    
        var source: [[STDetailRows]] = [[.Name, .Description],
                                        [.OpenInMaps],
                                        [.Height, .Width, .Shape]]
        
        if self.annotation?.tree.date != nil {
            source[0].append(.Birthday)
        }
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView = self.tableView.tableHeaderView
        self.tableView.tableHeaderView = nil
        
        if let headerView = self.headerView {
            self.tableView.addSubview(headerView)
            
            var contentInset = UIEdgeInsets()
            contentInset.top = STDefaultTableViewHeaderHeight
            
            self.tableView.contentInset = contentInset
            self.tableView.contentOffset = CGPoint(x: 0, y: -STDefaultTableViewHeaderHeight)
            
            self.updateHeaderView()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.annotation?.tree.speciesName
        self.tableView.estimatedRowHeight = STEstimateRowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.clearsSelectionOnViewWillAppear = true
        self.setupMapView()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {        
        self.updateHeaderView()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupMapView()
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
            if var image = self.treeDescription?.image() {
                self.resize(image: &image)
                basicCell.accessoryView = UIImageView(image: image)
            }
        case .Description:
            content = self.treeDescription?.treeDescription ?? "Tree Description Missing"
        case .Height:
            let height = self.localizedHeight()
            content = height.content
            subtitle = height.subtitle
        case .Width:
            let width = self.localizedWidth()
            content = width.content
            subtitle = width.subtitle
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
        
        return (subtitle:"Average Height", content: self.localizedLength(minimum, maximum: maximum))
    }
    
    func localizedLength(minimum: Double, maximum: Double) -> String {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Medium
        
        let unitType: NSLengthFormatterUnit
        let locale = NSLocale.autoupdatingCurrentLocale()
        let isMetric = locale.objectForKey(NSLocaleUsesMetricSystem) as? Bool
        if isMetric == true {
            unitType = .Meter
        } else {
            unitType = .Foot
        }
        
        let minimumString = formatter.stringFromValue(minimum, unit: unitType)
        let maximumString = formatter.stringFromValue(maximum, unit: unitType)
        
        return "\(minimumString) - \(maximumString)"
    }
    
    func localizedWidth() -> (subtitle: String, content: String) {
        guard let minimum = self.annotation?.tree.treeDescription?.minWidth?.doubleValue else {
            return (subtitle:"Error", content: "Getting minimum width")
        }
        guard let maximum = self.annotation?.tree.treeDescription?.maxWidth?.doubleValue else {
            return (subtitle:"Error", content: "Getting maximum width")
        }
        
        return (subtitle:"Average Width", content: self.localizedLength(minimum, maximum: maximum))
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
    
    func resize(inout image anImage: UIImage) {
        let newSize = STCellAccessorySize
        let newImageFrame = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.mainScreen().scale)
        anImage.drawInRect(newImageFrame)
        anImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func setupMapView() {
        guard let annotation = self.annotation else { return }
        
        let snapshot = STFKMapSnapshot(coordinate: annotation.coordinate) { (image, error) in
            self.mapImageView.image = image
        }
        
        snapshot.showDropPin = true
        snapshot.showPointsOfInterest = false
        snapshot.mapType = .Hybrid
        snapshot.distance = STSnapshotDistance
        snapshot.size = UIScreen.mainScreen().bounds.size
        snapshot.takeSnapshot()

    }
    
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0.0, y: -STDefaultTableViewHeaderHeight, width: self.tableView.bounds.width, height: STDefaultTableViewHeaderHeight)
        
        if self.tableView.contentOffset.y < STDefaultTableViewHeaderHeight {
            headerRect.origin.y = self.tableView.contentOffset.y
            headerRect.size.height = -self.tableView.contentOffset.y
        }
        
        self.headerView?.frame = headerRect
    }
}
