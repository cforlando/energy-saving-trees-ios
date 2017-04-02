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
private let STTimerInterval: TimeInterval = 60.0
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
    func addressFormViewController(_ form: STAddressFormViewController, didCompleteWithAddress anAddress: STTKStreetAddress)
}

//**********************************************************************************************************************
// MARK: - Typealias

typealias STValidAddressHandler = (_ valid: Bool) -> Void

//**********************************************************************************************************************
// MARK: - Class Impletementation

class STAddressFormViewController: STBaseOrderFormViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView! {
        didSet {
            mapImageView.layer.cornerRadius = STCornerRadius
            mapImageView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    fileprivate var timer: Timer?
    fileprivate var locationRequest: STFKLocationRequest?
    fileprivate var postalAddress = CNMutablePostalAddress()
    fileprivate var updatingAddress = CNPostalAddress()
    
    //******************************************************************************************************************
    // MARK: - ViewController Overrides
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if !self.confirmAddress() {
            return false
        }
        
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startLocationTimer()
        self.timer?.fire()
        
        self.postalAddress.country = "United States"
        self.postalAddress.city = "Orlando"
        self.postalAddress.state = "Florida"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        self.timer = nil
    }


    //******************************************************************************************************************
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        
        self.streetAddressTextField.resignFirstResponder()
        self.streetAddressTwoTextField.resignFirstResponder()
        self.zipCodeTextField.resignFirstResponder()
    }
    
    @IBAction func requestAddress(_ sender: UIButton) {
        
        self.streetAddressTextField.text = self.updatingAddress.street
        self.zipCodeTextField.text = self.updatingAddress.postalCode
        self.postalAddress.street = self.updatingAddress.street
        self.postalAddress.postalCode = self.updatingAddress.postalCode
    }
    
    //******************************************************************************************************************
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    func confirmAddress() -> Bool {
        
        guard let streetAddress = self.streetAddressTextField.text, streetAddress.isEmpty == false else {
            self.showAlert(STAddressWarningTitle, message: STAddressWarningMessage)
            return false
        }
        
        guard let zipCodeString = self.zipCodeTextField.text, zipCodeString.isEmpty == false else {
            self.showAlert(STZipCodeWarningTitle, message: STZipCodeWarningMessage)
            return false
        }
        
        guard let zipCode = UInt(zipCodeString), zipCodeString.characters.count == STZipCodeCount else {
            self.showAlert(STZipCodeInvalidWarningTitle, message: STZipCodeInvalidWarningMessage)
            return false
        }
        
        let streetAddressTwo = self.streetAddressTwoTextField.text ?? ""
        
        let address = STTKStreetAddress(streetAddress: streetAddress,
                                        secondaryAddress: streetAddressTwo,
                                        city: self.postalAddress.city,
                                        state: self.postalAddress.state,
                                        zipCode: zipCode,
                                        country: self.postalAddress.country)
        
        self.address = address
        
        self.delegate?.addressFormViewController(self, didCompleteWithAddress: address)
        
        return true
    }
    
    func createSnapshot(fromLocation aLocation: CLLocation) {
        
        let snapshot = STFKMapSnapshot(coordinate: aLocation.coordinate) { [weak self] (image: UIImage?, error: NSError?) in
            guard let mapImage = image, let strongSelf = self else {
                return
            }
            strongSelf.mapImageView.isHidden = false
            strongSelf.mapImageView.contentMode = .center
            strongSelf.mapImageView.image = mapImage
        }
        
        snapshot.takeSnapshot()
        
        self.requestGeolocation(aLocation)
    }
    
    func requestGeolocation(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [unowned self] (placeMarks: [CLPlacemark]?, error: NSError?) in
            guard let placeMark = placeMarks?.last else {
                self.showPlacemarkError(error)
                return
            }
            
            self.updateAddress(placeMark)
        } as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler
    }
    
    func showLocationError(_ error: NSError?) {
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
    
    func showPlacemarkError(_ error: NSError?) {
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
    
    func startLocationTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: STTimerInterval,
                                               target: self,
                                               selector: #selector(self.updateLocation),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    func updateAddress(_ placeMark: CLPlacemark) {
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.city = placeMark.string(forKey: STAddressDictionaryCityKey)
        postalAddress.street = placeMark.string(forKey: STAddressDictionaryStreetKey)
        postalAddress.state = placeMark.string(forKey: STAddressDictionaryStateKey)
        postalAddress.country = placeMark.string(forKey: STAddressDictionaryCountryKey)
        postalAddress.postalCode = placeMark.string(forKey: STAddressDictionaryPostalCodeKey)
        postalAddress.isoCountryCode = placeMark.string(forKey: STAddressDictionaryCountryCodeKey)
        
        self.updatingAddress = postalAddress
        
        let addressFormatter = CNPostalAddressFormatter()
        self.currentLocationLabel.text = addressFormatter.string(from: postalAddress)
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
