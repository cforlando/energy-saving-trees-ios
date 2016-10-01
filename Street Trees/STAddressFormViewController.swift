//
//  STAddressFormViewController.swift
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
import StreetTreesFoundationKit
import StreetTreesTransportKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STAddressDictionaryCityKey = "City"
private let STAddressDictionaryCountryCodeKey = "CountryCode"
private let STAddressDictionaryCountryKey = "Country"
private let STAddressDictionaryPostalCodeKey = "ZIP"
private let STAddressDictionaryStateKey = "State"
private let STAddressDictionaryStreetKey = "Street"
private let STAddressRequestErrorMessage = "An error occured while requesting your address. Please try again."
private let STAddressRequestErrorTitle = "Address Request Error"
private let STAddressWarningMessage = "Please add a street address that the tree should be delivered to."
private let STAddressWarningTitle = "Missing Street Address"
private let STBorderWidth: CGFloat = 1.0
private let STCornerRadius: CGFloat = 4.0
private let STLocationAccuracy: CLLocationAccuracy = 5.0
private let STLocationErrorTitle = "Location Error"
private let STTimerInterval: NSTimeInterval = 60.0
private let STUnknownErrorTitle = "Unknown Error"
private let STUnknownLocationErrorMessage = "An error occured while requesting your location. Please try again."
private let STZipCodeCount = 5
private let STZipCodeInvalidWarningMessage = "Please enter a valid zip code."
private let STZipCodeInvalidWarningTitle = "Invalid Zip Code"
private let STZipCodeWarningMessage = "Please add the zip code that the tree should be delivered to."
private let STZipCodeWarningTitle = "Missing Zip Code"

//**********************************************************************************************************************
// MARK: - Extensions

private extension CLPlacemark {
    func string(forKey aKey: String) -> String {
        return self.addressDictionary?[aKey] as? String ?? ""
    }
}

//**********************************************************************************************************************
// MARK: - Protocols

protocol STAddressFormViewControllerDelegate: NSObjectProtocol {
    func addressFormViewController(form: STAddressFormViewController, didCompleteWithAddress anAddress: STTKStreetAddress)
}

//**********************************************************************************************************************
// MARK: - Class Impletementation

class STAddressFormViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView! {
        didSet {
            mapImageView.layer.cornerRadius = STCornerRadius
            mapImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            mapImageView.layer.borderWidth = STBorderWidth
        }
    }
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var streetAddressTwoTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var zipCodeTextField: UITextField! {
        didSet {
            zipCodeTextField.inputAccessoryView = toolBar
        }
    }
    
    weak var delegate: STAddressFormViewControllerDelegate?
    
    private lazy var timer: NSTimer? = {
        return NSTimer.scheduledTimerWithTimeInterval(STTimerInterval,
                                                      target: self,
                                                      selector: #selector(self.updateLocation),
                                                      userInfo: nil,
                                                      repeats: true)
    }()
    
    private var activeTextField: UITextField?
    private var locationRequest: STFKLocationRequest?
    private var postalAddress = CNMutablePostalAddress()
    private(set) var updatingAddress = CNPostalAddress()
    
    //******************************************************************************************************************
    // MARK: - ViewController Overrides
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timer?.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        self.timer = nil
    }

    //******************************************************************************************************************
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        
        self.streetAddressTextField.resignFirstResponder()
        self.streetAddressTwoTextField.resignFirstResponder()
        self.zipCodeTextField.resignFirstResponder()
    }
    
    @IBAction func nextButton(sender: UIButton) {
        
        guard let streetAddress = self.streetAddressTextField.text where streetAddress.isEmpty == false else {
            self.showAlert(STAddressWarningTitle, message: STAddressWarningMessage)
            return
        }
        
        guard let zipCodeString = self.zipCodeTextField.text where zipCodeString.isEmpty == false else {
            self.showAlert(STZipCodeWarningTitle, message: STZipCodeWarningMessage)
            return
        }
        
        guard let zipCode = UInt(zipCodeString) where zipCodeString.characters.count == STZipCodeCount else {
            self.showAlert(STZipCodeInvalidWarningTitle, message: STZipCodeInvalidWarningMessage)
            return
        }
        
        let streetAddressTwo = self.streetAddressTwoTextField.text ?? ""
        
        let address = STTKStreetAddress(streetAddress: streetAddress,
                                        secondaryAddress: streetAddressTwo,
                                        city: self.postalAddress.city,
                                        state: self.postalAddress.state,
                                        zipCode: zipCode,
                                        country: self.postalAddress.country)
        
        self.delegate?.addressFormViewController(self, didCompleteWithAddress: address)
    }
    
    @IBAction func requestAddress(sender: UIButton) {
        
        self.streetAddressTextField.text = self.updatingAddress.street
        self.zipCodeTextField.text = self.updatingAddress.postalCode
        self.postalAddress.street = self.updatingAddress.street
        self.postalAddress.postalCode = self.updatingAddress.postalCode
    }
    
    //******************************************************************************************************************
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.streetAddressTextField:
            self.postalAddress.street = self.streetAddressTextField.text ?? ""
            self.streetAddressTwoTextField.becomeFirstResponder()
            return false
        case self.streetAddressTwoTextField:
            self.postalAddress.street = self.postalAddress.street + "\n\(self.streetAddressTwoTextField.text ?? "")"
            self.zipCodeTextField.becomeFirstResponder()
            return false
        case self.zipCodeTextField:
            self.postalAddress.postalCode = self.zipCodeTextField.text ?? ""
            fallthrough
        default:
            return true
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    func createSnapshot(fromLocation aLocation: CLLocation) {
        
        let snapshot = STFKMapSnapshot(location: aLocation) { [unowned self] (image: UIImage?, error: NSError?) in
            guard let mapImage = image else {
                return
            }
            self.mapImageView.hidden = false
            self.mapImageView.contentMode = .Center
            self.mapImageView.image = mapImage
        }
        
        snapshot.takeSnapshot()
        
        self.requestGeolocation(aLocation)
    }
    
    func requestGeolocation(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [unowned self] (placeMarks: [CLPlacemark]?, error: NSError?) in
            guard let placeMark = placeMarks?.last else {
                self.showPlacemarkError(error)
                return
            }
            
            self.updateAddress(placeMark)
        }
    }
    
    func showLocationError(error: NSError?) {
        let title: String
        let message: String
        
        if let safeError = error {
            title = STLocationErrorTitle
            message = safeError.localizedDescription
        } else {
            title = STUnknownErrorTitle
            message = STUnknownLocationErrorMessage
        }
        
        self.showAlert(title, message: message)
    }
    
    func showPlacemarkError(error: NSError?) {
        let title: String
        let message: String
        
        if let safeError = error {
            title = STAddressRequestErrorTitle
            message = safeError.localizedDescription
        } else {
            title = STUnknownErrorTitle
            message = STAddressRequestErrorMessage
        }
        
        self.showAlert(title, message: message)
    }
    
    func updateAddress(placeMark: CLPlacemark) {
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.city = placeMark.string(forKey: STAddressDictionaryCityKey)
        postalAddress.street = placeMark.string(forKey: STAddressDictionaryStreetKey)
        postalAddress.state = placeMark.string(forKey: STAddressDictionaryStateKey)
        postalAddress.country = placeMark.string(forKey: STAddressDictionaryCountryKey)
        postalAddress.postalCode = placeMark.string(forKey: STAddressDictionaryPostalCodeKey)
        postalAddress.ISOCountryCode = placeMark.string(forKey: STAddressDictionaryCountryCodeKey)
        
        self.updatingAddress = postalAddress
        
        let addressFormatter = CNPostalAddressFormatter()
        self.currentLocationLabel.text = addressFormatter.stringFromPostalAddress(postalAddress)
    }
    
    func updateLocation() {
        self.locationRequest = STFKLocationRequest(accuracy: STLocationAccuracy) { [unowned self] (location: CLLocation?, error: NSError?) in
            self.locationRequest = nil
            
            guard let safeLocation = location else {
                self.showLocationError(error)
                return
            }
            self.createSnapshot(fromLocation: safeLocation)
        }
    }

}
