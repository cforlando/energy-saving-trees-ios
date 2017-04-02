//
//  STUserDetailsFormViewController.swift
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

import StreetTreesTransportKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STContactErrorTitle = "Error"
private let STContactErrorNameMessage = "Please enter a name."
private let STContactErrorEmailMessage = "Please enter a valid email address."
private let STContactErrorNumberMessage = "Please enter a valid phone number."

//**********************************************************************************************************************
// MARK: - Enumerations

enum STValidation {
    case phoneNumber, email
    
    func regex() -> String {
        switch self {
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        case .phoneNumber:
            return "^(?:(?:\\+?1\\s*(?:[.-]\\s*)?)?(?:\\(\\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\\s*\\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\\s*(?:[.-]\\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?$"
        }
    }
}

//**********************************************************************************************************************
// MARK: - Protocol

protocol STContactDetailsFormViewControllerDelegate: NSObjectProtocol {
    func contactDetailsFormViewController(_ form: STContactDetailsFormViewController, didCompleteWithContact aContact: STTKContact)
}


//**********************************************************************************************************************
// MARK: - Class Implementation

class STContactDetailsFormViewController: STBaseOrderFormViewController {
    
    weak var delegate: STContactDetailsFormViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField! {
        didSet {
            self.phoneNumberTextField.inputAccessoryView = self.toolbar
        }
    }
    @IBOutlet weak var toolbar: UIToolbar!
    
    //******************************************************************************************************************
    // MARK: - ViewController Overrides
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if !self.confirmUser() {
            return false
        }
        
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
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
        case self.nameTextField:
            self.emailTextField.becomeFirstResponder()
            return false
        case self.emailTextField:
            self.phoneNumberTextField.becomeFirstResponder()
            return false
        case self.phoneNumberTextField:
            fallthrough
        default:
            return true
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        self.nameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.phoneNumberTextField.resignFirstResponder()
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    func confirmUser() -> Bool {
        
        guard let name = self.nameTextField.text, !name.isEmpty else {
            self.showAlert(STContactErrorTitle, message: STContactErrorNameMessage)
            return false
        }
        
        guard let email = self.emailTextField.text, self.validate(string: email, validation: .email) else {
            self.showAlert(STContactErrorTitle, message: STContactErrorEmailMessage)
            return false
        }
        
        guard let phoneNumber = self.phoneNumberTextField.text, self.validate(string: phoneNumber, validation: .phoneNumber) else {
            self.showAlert(STContactErrorTitle, message: STContactErrorNumberMessage)
            return false
        }
        
        guard let safeAddress = self.address else {
            fatalError("An Address has not been passed.")
        }
        
        let contact = STTKContact(name: name, email: email, phoneNumber: phoneNumber, address: safeAddress)
        self.contact = contact
        self.delegate?.contactDetailsFormViewController(self, didCompleteWithContact: contact)
        return true
    }

    func validate(string aString: String, validation: STValidation) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", validation.regex()).evaluate(with: aString)
    }
  

}
