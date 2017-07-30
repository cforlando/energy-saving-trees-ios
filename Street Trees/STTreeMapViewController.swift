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
import FBAnnotationClustering
import MapKit
import SpriteKit
import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

private let STAnimationDuration: TimeInterval = 0.3
private let STArborDay = 20
private let STArborDayXOffset:CGFloat = 60.0
private let STArborDayYOffset:CGFloat = 140.0
private let STArborMonth = 4
private let STCityLimitsFillAlpha: CGFloat = 0.2
private let STCityLimitsLineWidth: CGFloat = 3.0
private let STClusterLargeImageName = "clusterLarge"
private let STClusterMediumImageName = "clusterMedium"
private let STClusterSmallImageName = "clusterSmall"
private let STLoadingMessage = "Loading..."
private let STMapPinReuseIdentifier = "com.streettrees.mapview.pin"
private let STMaximumAnnotationViewAlpha: CGFloat = 1.0
private let STMaximumTransformScale: CGFloat = 1.0
private let STMinimumAnnotationViewAlpha: CGFloat = 0.0
private let STMinimumTransformScale: CGFloat = 0.0
private let STRegionRadius: CLLocationDistance = 1000
private let STRegionRadiusDistance = STRegionRadius * 2.0
private let STSceneSize = CGSize(width: 120, height: 120)
private let STViewControllerTitle = "Street Trees"

class STTreeMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    lazy var clusteringManager: FBClusteringManager = {
        var annotations = [MKAnnotation]()
        for tree in self.fetchedResultsController.fetchedObjects ?? [] {
            
            let image = STPKTreeDescription.icon(treeName: tree.speciesName ?? "")
            let pin = STTreeAnnotation(tree: tree, image: image)
            
            annotations.append(pin)
        }
        return FBClusteringManager(annotations: annotations)
    }()
    
    let locationManager = CLLocationManager()
    var foundUser = false
    let spriteView = SKView(frame: CGRect(origin: .zero, size: STSceneSize))
    var treeEmitter = STPeaceEmitter()
    
    lazy var fetchedResultsController: NSFetchedResultsController<STPKTree> = {
        let fetchRequest = NSFetchRequest<STPKTree>(entityName: STPKTree.entityName())
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
    
    var isArborDay: Bool {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.month, .day], from: Date())
        return dateComponents.month == STArborMonth && dateComponents.day == STArborDay
    }
    
    var selectedAnnotation: STTreeAnnotation?
    var backgroundQueue = OperationQueue() {
        didSet {
            self.backgroundQueue.qualityOfService = .background
            self.backgroundQueue.name = "Geo Poly Mapping"
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let detailVC = segue.destination as? STTreeDetailsTableViewController, segue.identifier == STTreeDetailsSegueIdentifier {
            detailVC.annotation = self.selectedAnnotation
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        self.spriteView.allowsTransparency = true
        self.spriteView.presentScene(self.treeEmitter)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupLocation()
    }
    
    //******************************************************************************************************************
    // MARK: - Actions
    
    @IBAction func unwindToMapView(_ segue: UIStoryboardSegue) {
        // no op
    }
    
    //******************************************************************************************************************
    // MARK: - FetchedResultsController Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.loadPins()
    }
    
    //******************************************************************************************************************
    // MARK: - MKMapView Delegates

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if let treeAnnotation = view.annotation as? STTreeAnnotation {
            self.selectedAnnotation = treeAnnotation
        }
        self.performSegue(withIdentifier: STTreeDetailsSegueIdentifier, sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            
            if view is STAnnotationView {
                continue
            }
            
            let originalSize = view.transform
            view.alpha = STMinimumAnnotationViewAlpha
            
            let transform = originalSize.scaledBy(x: STMinimumTransformScale, y: STMinimumTransformScale)
            view.transform = transform
            
            UIView.animate(withDuration: STAnimationDuration, animations: {
                view.alpha = STMaximumAnnotationViewAlpha
                view.transform = originalSize.scaledBy(x: STMaximumTransformScale, y: STMaximumTransformScale)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        for renderer in renderers {
            renderer.alpha = STMinimumAnnotationViewAlpha
            UIView.animate(withDuration: STAnimationDuration, animations: {
                renderer.alpha = STMaximumAnnotationViewAlpha
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !self.foundUser {
            self.foundUser = true
            self.centerMapOnLocation(userLocation.location!)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.loadPins()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = UIColor.orlandoGreenColor()
            renderer.fillColor = UIColor.orlandoGreenColor(STCityLimitsFillAlpha)
            renderer.lineWidth = STCityLimitsLineWidth
            return renderer
        }
        
        return MKPolygonRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        var reuseId: String
        
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            let imageSize = STAnnotationView.Images(
                large: STClusterLargeImageName,
                medium: STClusterMediumImageName,
                small: STClusterSmallImageName
            )
            
            annotationView = STAnnotationView(annotation: annotation, reuseIdentifier: nil, images: imageSize)
            
        } else {
            reuseId = STMapPinReuseIdentifier
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            annotationView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
            
            if let treeLocation = annotation as? STTreeAnnotation {
                annotationView?.image = treeLocation.image
            }
        }
        
        return annotationView
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if mapView.overlays.count != 0 {
            return
        }
        
        self.backgroundQueue.addOperation { [weak self] in
            STPKCoreData.sharedInstance.fetchCityBounds({ (cityBounds, error) in
                guard let bounds = cityBounds else { return }
                
                defer {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                do {
                    let shapes = try bounds.shapes()
                    OperationQueue.main.addOperation({ [weak self] in
                        self?.mapView.addOverlays(shapes)
                    })

                } catch {
                    
                }
            })
        }
    }
    
    //******************************************************************************************************************
    // MARK: - CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Gesture Recogniser Delegates
    
    @IBAction func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        
        var locationInView = gesture.location(in: self.view)
        locationInView.x -= STArborDayXOffset
        locationInView.y -= STArborDayYOffset
        
        self.spriteView.frame.origin = locationInView
        
        switch gesture.state {
        case .began:
            self.view.addSubview(self.spriteView)
        case .changed:
            self.treeEmitter.beginAnimation()
        case .ended:
            self.treeEmitter.endAnimation()
            self.spriteView.removeFromSuperview()
        default:
            ()
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  STRegionRadiusDistance, STRegionRadiusDistance)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadPins() {
        OperationQueue().addOperation {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(within: self.mapView.visibleMapRect,
                                                                              withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, on:self.mapView)
        }
    }
    
    func setupLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted:
            self.locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.mapView.showsUserLocation = true
        default:
            ()
        }
    }
}



class STAnnotationView: MKAnnotationView {
    
    struct Images {
        let large: String
        let medium: String
        let small: String
        
        func image(for count: Int) -> UIImage? {
            if count > 30 {
                return UIImage(named: self.large)
            } else if count > 10 {
                return UIImage(named: self.medium)
            } else {
                return UIImage(named: self.small)
            }
        }
    }
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    let images: Images
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, images: Images) {
        self.images = images
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.updateClusterSize()
        self.updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.images = Images(large: "", medium: "", small: "")
        super.init(coder: aDecoder)
        self.updateView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = bounds
        layer.cornerRadius = image == nil ? bounds.size.width / 2 : 0
    }
    
    private func updateView() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.white.cgColor
        self.addSubview(self.countLabel)
    }
    
    private func updateClusterSize() {
        if let cluster = self.annotation as? FBAnnotationCluster {
            
            if cluster.annotations != nil {
                let count = cluster.annotations.count
                self.image = self.images.image(for: count)
                self.countLabel.text = "\(count)"
            }
            
            setNeedsLayout()
        }
    }
}


