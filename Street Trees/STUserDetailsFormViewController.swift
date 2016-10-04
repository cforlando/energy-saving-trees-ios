//
//  STUserDetailsFormViewController.swift
//  Street Trees
//
//  Created by Tom Marks on 1/10/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
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
    case PhoneNumber, Email
    
    func regex() -> String {
        switch self {
        case .Email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        case .PhoneNumber:
            return "^(?:(?:\\+?1\\s*(?:[.-]\\s*)?)?(?:\\(\\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\\s*\\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\\s*(?:[.-]\\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?$"
        }
    }
}

//**********************************************************************************************************************
// MARK: - Protocol

protocol STContactDetailsFormViewControllerDelegate: NSObjectProtocol {
    func contactDetailsFormViewController(form: STContactDetailsFormViewController, didCompleteWithContact aContact: STTKContact)
}

//**********************************************************************************************************************
// MARK: - Class Implementation

class STContactDetailsFormViewController: UIViewController {
    
    var activeTextField: UITextField?
    var address: STTKStreetAddress?
    
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
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.nameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.phoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func nextButton(sender: UIButton) {
        
        guard let name = self.nameTextField.text where !name.isEmpty else {
            self.showAlert(STContactErrorTitle, message: STContactErrorNameMessage)
            return
        }
        
        guard let email = self.emailTextField.text where self.validate(string: email, validation: .Email) else {
            self.showAlert(STContactErrorTitle, message: STContactErrorEmailMessage)
            return
        }
        
        guard let phoneNumber = self.phoneNumberTextField.text where self.validate(string: phoneNumber, validation: .PhoneNumber) else {
            self.showAlert(STContactErrorTitle, message: STContactErrorNumberMessage)
            return
        }
        
        guard let safeAddress = self.address else {
            fatalError("An Address has not been passed.")
        }
        
        let contact = STTKContact(name: name, email: email, phoneNumber: phoneNumber, address: safeAddress)
        self.delegate?.contactDetailsFormViewController(self, didCompleteWithContact: contact)
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions

    func validate(string aString: String, validation: STValidation) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", validation.regex()).evaluateWithObject(aString)
    }
}
