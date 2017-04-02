//
//  STConfirmationPageViewController.swift
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

import Contacts
import CoreLocation
import MapKit
import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants:

private let ST4InchHeight: CGFloat = 568.0
private let STAlertDismissButtonTitle = "OK"
private let STConfirmButtonTitle = "Confirm"
private let STContactErrorMessage = "Contact information has not been passed."
private let STInvalidLocationMessage = "Please make sure you are requesting a tree to a location within the City of Orlando."
private let STInvalidLocationTite = "Service Unavailable"
private let STOrderCompleteMessage = "Thank You! Your request has been sent."
private let STOrderCompleteTitle = "Order Complete"
private let STProgressComplete: Float = 1.0
private let STSegueIdentifierUnwindToMapView = "unwindToMapView"
private let STSendingFormMessage = "Requesting tree..."
private let STSendingFormTitle = "Sending Request"
private let STTreeErrorNameMessage = "Tree name has not been passed."
private let STTreeErrorTitle = "Error"

//**********************************************************************************************************************

class STConfirmationPageViewController: STBaseOrderFormViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var treeImage: UIImageView!
    @IBOutlet weak var treeName: UILabel!
    
    var alertController: UIAlertController?
    let geocoder = CLGeocoder()
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIScreen.main.nativeBounds.height / UIScreen.main.nativeScale < ST4InchHeight {
            self.contactLabel.isHidden = true
            self.deliveryLabel.isHidden = true
        }
        
        self.treeImage.image = self.treeDescription?.image()
        self.treeName.text = self.treeDescription?.name
        self.addressLabel.text = self.address?.localizedAddress()
        self.nameLabel.text = self.contact?.name
        self.emailLabel.text = self.contact?.email
        self.phoneNumberLabel.text = self.contact?.phoneNumber
    }
    
    //******************************************************************************************************************
    // MARK: - Actions:
    
    @IBAction func confirmButtonItemTouchUpInside(_ sender: AnyObject) {
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.startAnimating()
        
        let barButton = UIBarButtonItem(customView: activityView)
        self.navigationItem.rightBarButtonItem = barButton
        
        if let navigationController = self.navigationController as? STOrderFormNavigationViewController {
            navigationController.progressBar.setProgress(STProgressComplete, animated: true)
        }
        
        self.alertController = UIAlertController(title: STSendingFormTitle, message: STSendingFormMessage, preferredStyle: .alert)
        
        self.present(self.alertController!, animated: true) {
            self.submitForm()
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions

    func resetUI() {
        if let navigationController = self.navigationController as? STOrderFormNavigationViewController {
            navigationController.updateProgress(self)
        }
        
        let barButton = UIBarButtonItem(title: STConfirmButtonTitle, style: .plain, target: self, action: #selector(self.confirmButtonItemTouchUpInside(_:)))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func submitForm() {
        guard let treeName = treeDescription?.name else {
            self.showAlert(STTreeErrorTitle, message: STTreeErrorNameMessage)
            return
        }
        
        guard let safeContact = self.contact else {
            self.showAlert(STTreeErrorTitle, message: STContactErrorMessage)
            return
        }
        
        self.validAddress { [weak self] (valid) in
            if !valid {
                self?.dismiss(animated: true, completion: {
                    self?.resetUI()
                    self?.showAlert(STInvalidLocationTite, message: STInvalidLocationMessage)
                })
                return
            }
            
            let wufooRequest = STTKWufooRequest()
            let wufooForm = STTKWufooForm(tree: treeName, forContact: safeContact)
            
            wufooRequest.execute(wufooForm) { (error: NSError?) in
                guard let safeSelf = self else { return }
                
                let okAction = UIAlertAction(title: STAlertDismissButtonTitle, style: .Default) { [weak self] _ in
                    self?.performSegueWithIdentifier(STSegueIdentifierUnwindToMapView, sender: self)
                }
                
                safeSelf.alertController?.addAction(okAction)
                
                if let safeError = error {
                    safeSelf.alertController?.title = STTreeErrorTitle
                    safeSelf.alertController?.message = safeError.localizedFailureReason
                    return
                }
                
                safeSelf.alertController?.title = STOrderCompleteTitle
                safeSelf.alertController?.message = STOrderCompleteMessage
            }
        }
    }
    
    func validAddress(_ handler: @escaping STValidAddressHandler) {
        
        let address = self.address?.flatAddress() ?? ""
        self.geocoder.geocodeAddressString(address) { (placemarks:[CLPlacemark]?, error:NSError?) in
            if let _ = error {
                handler(valid: false)
                return
            }
            
            STPKCoreData.sharedInstance.fetchCityBounds({ (cityBounds, error) in
                if let _ = error {
                    handler(valid: true)
                    return
                }
                
                let shapes: [MKPolygon]
                do {
                    shapes = try cityBounds?.shapes() ?? []
                } catch {
                    handler(valid: true)
                    return
                }
                
                for placemark in placemarks ?? [] {
                    guard let coordinate = placemark.location?.coordinate else {
                        continue
                    }
                    
                    for shape in shapes {
                        if shape.coordinateInsidePolygon(coordinate) {
                            handler(valid: true)
                            return
                        }
                    }
                }
                
                handler(valid: false)
            })
        }
    }
}
