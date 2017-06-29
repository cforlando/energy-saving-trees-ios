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
    case additional
    case description
    case height
    case leaf
    case moisture
    case name
    case openInMaps
    case shape
    case soil
    case width
    case birthday
    
    func sectionHeader() -> String? {
        switch self {
        case .additional:
            return "Additional"
        case .openInMaps, .birthday:
            return nil
        case .name, .description:
            return nil
        case .width, .height, .shape:
            return "Dimensions"
        case .soil, .moisture, .leaf:
            return "Foilage and Environment"
        }
    }
}

class STTreeDetailsTableViewController: UITableViewController {

    @IBOutlet weak var mapImageView: UIImageView!
    
    var annotation: STTreeAnnotation?
    var headerView: UIView?
    var treeDescription: STPKTreeDescription? {
        return self.annotation?.tree.treeDescription
    }
    
    lazy var datasource: [[STDetailRows]] = {
    
        var source: [[STDetailRows]] = [[.name, .description],
                                        [.openInMaps],
                                        [.height, .width, .shape]]
        
        if self.annotation?.tree.date != nil {
            source[0].append(.birthday)
        }
        
        var foilageAndEnvironment: [STDetailRows] = [.leaf, .soil]
        if self.treeDescription?.moisture != nil {
            foilageAndEnvironment.append(.moisture)
        }
        
        source.append(foilageAndEnvironment)
        
        if self.treeDescription?.additional != nil {
            source.append([.additional])
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.annotation?.tree.speciesName
        self.tableView.estimatedRowHeight = STEstimateRowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.clearsSelectionOnViewWillAppear = true
        self.setupMapView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        self.updateHeaderView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupMapView()
    }
    
    //******************************************************************************************************************
    // MARK: - TableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.datasource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        
        let row = self.detailRow(forIndexPath: indexPath)
        let content: String
        var subtitle: String? = nil
        basicCell.selectionStyle = .none
        
        switch row {
        case .name:
            content = self.treeDescription?.name ?? "Error retrieving name"
            if var image = self.treeDescription?.image() {
                self.resize(image: &image)
                basicCell.accessoryView = UIImageView(image: image)
            }
        case .description:
            content = self.treeDescription?.treeDescription ?? "Tree Description Missing"
        case .height:
            let height = self.localizedHeight()
            content = height.content
            subtitle = height.subtitle
        case .width:
            let width = self.localizedWidth()
            content = width.content
            subtitle = width.subtitle
        case .openInMaps:
            content = "Open in Maps"
        case .leaf:
            content = self.treeDescription?.leaf ?? "Leaf information missing"
            subtitle = "Leaf"
        case .shape:
            content = self.treeDescription?.shape ?? "Shape information missing"
            subtitle = "Shape"
        case .soil:
            let soil = self.treeDescription?.soil
            content = soil?.stringByReplacingOccurrencesOfString(";", withString: ", ") ?? "Soil information missing"
            subtitle = "Soil"
        case .moisture:
            content = self.treeDescription?.moisture ?? "Moisture information missing"
            subtitle = "Moisture"
        case .additional:
            content = self.treeDescription?.additional ?? "Additional information missing"
        case .birthday:
            if let date = self.annotation?.tree.date {
                let dateString = DateFormatter.localizedStringFromDate(date, dateStyle: .medium, timeStyle: .none)
                content = dateString
            } else {
                content = "No Date Available"
            }
        }
        
        basicCell.textLabel?.text = content
        basicCell.detailTextLabel?.text = subtitle
        
        return basicCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rows = self.datasource[section]
        return rows.first?.sectionHeader()
    }
    
    //******************************************************************************************************************
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let detail = self.detailRow(forIndexPath: indexPath)
        
        return detail == .openInMaps ? indexPath : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailRow = self.detailRow(forIndexPath: indexPath)
        
        if detailRow == .openInMaps {
            self.openInMaps()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Functions
    
    func detailRow(forIndexPath anIndexPath: IndexPath) -> STDetailRows {
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
    
    func localizedLength(_ minimum: Double, maximum: Double) -> String {
        let formatter = LengthFormatter()
        formatter.isForPersonHeightUse = true
        formatter.unitStyle = .medium
        
        let unitType: LengthFormatter.Unit
        let locale = Locale.autoupdatingCurrent
        let isMetric = (locale as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as? Bool
        if isMetric == true {
            unitType = .meter
        } else {
            unitType = .foot
        }
        
        let minimumString = formatter.string(fromValue: minimum, unit: unitType)
        let maximumString = formatter.string(fromValue: maximum, unit: unitType)
        
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
            let URL = URL(string: "http://maps.apple.com/maps?q=\(latitude),\(longitude)"){
            
            if UIApplication.sharedApplication().canOpenURL(URL) {
                UIApplication.sharedApplication().openURL(URL)
            } else {
                self.showAlert("Oops", message: "Street Trees was unable to open maps.")
            }
        } else {
            self.showAlert("Oops", message: "Something went wrong getting the location of the tree.")
        }
    }
    
    func resize(image anImage: inout UIImage) {
        let newSize = STCellAccessorySize
        let newImageFrame = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.main.scale)
        anImage.draw(in: newImageFrame)
        anImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    func setupMapView() {
        guard let annotation = self.annotation else { return }
        
        let snapshot = STFKMapSnapshot(coordinate: annotation.coordinate) { (image, error) in
            self.mapImageView.image = image
        }
        
        snapshot.showDropPin = true
        snapshot.showPointsOfInterest = false
        snapshot.mapType = .hybrid
        snapshot.distance = STSnapshotDistance
        snapshot.size = UIScreen.main.bounds.size
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
