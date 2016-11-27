//
//  STTreeMapViewController.swift
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

import CoreData
import CoreLocation
import FBAnnotationClusteringSwift
import MapKit
import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

private let STAnimationDuration: NSTimeInterval = 0.3
private let STCityLimitsFillAlpha: CGFloat = 0.2
private let STCityLimitsLineWidth: CGFloat = 3.0
private let STClusterLargeImageName = "clusterLarge"
private let STClusterMediumImageName = "clusterMedium"
private let STClusterSmallImageName = "clusterSmall"
private let STMapPinReuseIdentifier = "com.streettrees.mapview.pin"
private let STMaximumAnnotationViewAlpha: CGFloat = 1.0
private let STMaximumTransformScale: CGFloat = 1.0
private let STMinimumAnnotationViewAlpha: CGFloat = 0.0
private let STMinimumTransformScale: CGFloat = 0.0
private let STRegionRadius: CLLocationDistance = 1000
private let STRegionRadiusDistance = STRegionRadius * 2.0
private let STViewControllerTitle = "Street Trees"
private let STLoadingMessage = "Loading..."

class STTreeMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let clusteringManager = FBClusteringManager()
    let locationManager = CLLocationManager()
    var foundUser = false
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: STPKTree.entityName())
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let context = STPKCoreData.sharedInstance.coreDataStack?.mainQueueContext()
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            
        }
        return controller
    }()
    
    var isInOrlando: Bool {
        if self.foundUser {
            let userCoordinate = self.mapView.userLocation.coordinate
            let userMapPoint = MKMapPointForCoordinate(userCoordinate)
            var isInside = false
            for overlay in self.mapView.overlays {
                if let renderer = self.mapView.rendererForOverlay(overlay) as? MKPolygonRenderer {
                    let polygonPoint = renderer.pointForMapPoint(userMapPoint)
                    isInside = CGPathContainsPoint(renderer.path, nil, polygonPoint, false)
                    if isInside {
                        return isInside
                    }
                }
            }
        }
        
        return false
    }
    
    var selectedAnnotation: STTreeAnnotation?
    var backgroundQueue = NSOperationQueue() {
        didSet {
            self.backgroundQueue.qualityOfService = .Background
            self.backgroundQueue.name = "Geo Poly Mapping"
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let detailVC = segue.destinationViewController as? STTreeDetailsTableViewController
            where segue.identifier == STTreeDetailsSegueIdentifier {
            detailVC.annotation = self.selectedAnnotation
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.loadPinsToMap()
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.locationManager.delegate = self
        self.setupLocation()
    }
    
    //******************************************************************************************************************
    // MARK: - FetchedResultsController Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.loadPinsToMap()
    }
    
    //******************************************************************************************************************
    // MARK: - MKMapView Delegates

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if let treeAnnotation = view.annotation as? STTreeAnnotation {
            self.selectedAnnotation = treeAnnotation
        }
        self.performSegueWithIdentifier(STTreeDetailsSegueIdentifier, sender: self)
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            
            if view is FBAnnotationClusterView {
                continue
            }
            
            let originalSize = view.transform
            view.alpha = STMinimumAnnotationViewAlpha
            
            let transform = CGAffineTransformScale(originalSize, STMinimumTransformScale, STMinimumTransformScale)
            view.transform = transform
            
            UIView.animateWithDuration(STAnimationDuration, animations: {
                view.alpha = STMaximumAnnotationViewAlpha
                view.transform = CGAffineTransformScale(originalSize, STMaximumTransformScale, STMaximumTransformScale)
            })
        }
    }
    
    func mapView(mapView: MKMapView, didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        for renderer in renderers {
            renderer.alpha = STMinimumAnnotationViewAlpha
            UIView.animateWithDuration(STAnimationDuration, animations: {
                renderer.alpha = STMaximumAnnotationViewAlpha
            })
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !self.foundUser {
            self.foundUser = true
            self.centerMapOnLocation(userLocation.location!)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.loadPins()
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = UIColor.orlandoGreenColor()
            renderer.fillColor = UIColor.orlandoGreenColor(STCityLimitsFillAlpha)
            renderer.lineWidth = STCityLimitsLineWidth
            return renderer
        }
        
        return MKPolygonRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        var reuseId: String
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            let imageSize = FBAnnotationClusterViewOptions(smallClusterImage: STClusterSmallImageName,
                                                           mediumClusterImage: STClusterMediumImageName,
                                                           largeClusterImage: STClusterLargeImageName)
            
            annotationView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: nil, options: imageSize)
            
        } else {
            reuseId = STMapPinReuseIdentifier
            annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            annotationView?.canShowCallout = true
            let button = UIButton(type: .DetailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
            
            if let treeLocation = annotation as? STTreeAnnotation {
                annotationView?.image = treeLocation.image
            }
        }
        
        return annotationView
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        if mapView.overlays.count != 0 {
            return
        }
        
        self.backgroundQueue.addOperationWithBlock { [weak self] in
            STTKDownloadManager.fetch(cityGeoPoints: { (response: [AnyObject]) in
                if let polygons = response as? [MKPolygon] {
                    self?.mapView.addOverlays(polygons)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
        }
    }
    
    //******************************************************************************************************************
    // MARK: - CLLocationManager Delegates
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            self.mapView.showsUserLocation = true
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  STRegionRadiusDistance, STRegionRadiusDistance)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadPins() {
        NSOperationQueue().addOperationWithBlock {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect,
                withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        }
    }
    
    func loadPinsToMap() {
        
        if self.mapView.annotations.count > 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.clusteringManager.setAnnotations([])
        }
        
        var clusters:[FBAnnotation] = []
        for tree in self.fetchedResultsController.fetchedObjects as? [STPKTree] ?? [] {
            
            let image = STPKTreeDescription.icon(treeName: tree.speciesName ?? "")
            let pin = STTreeAnnotation(tree: tree, image: image)
            
            self.mapView.addAnnotation(pin)
            clusters.append(pin)
        }
        self.clusteringManager.addAnnotations(clusters)
        self.loadPins()
    }
    
    func setupLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined, .Restricted:
            self.locationManager.requestAlwaysAuthorization()
        case .AuthorizedAlways:
            self.mapView.showsUserLocation = true
        default:
            ()
        }
    }
}
