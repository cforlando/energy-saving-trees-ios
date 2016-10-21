//
//  STOrderFormNavigationViewController.swift
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

import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

class STOrderFormNavigationViewController: UINavigationController, UINavigationControllerDelegate,
TreeDescription, Address, Contact, STContactDetailsFormViewControllerDelegate, STSelectTreeViewControllerDelegate,
STAddressFormViewControllerDelegate,STConfirmationPageViewControllerDelegate {

    var treeDescription: STPKTreeDescription?
    var address: STTKStreetAddress?
    var contact: STTKContact?
    
    var wufooForm: STTKWufooForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    
        // Do any additional setup after loading the view.
    }
    
    //******************************************************************************************************************
    // MARK: - NavigationController Delegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        var treeController = viewController as? TreeDescription
        treeController?.treeDescription = self.treeDescription
        
        var addressController = viewController as? Address
        addressController?.address = self.address
        
        var contactController = viewController as? Contact
        contactController?.contact = self.contact
        
        if let userController = viewController as? STContactDetailsFormViewController {
            userController.delegate = self
        }
        
        if let treeViewController = viewController as? STSelectTreeViewController {
            treeViewController.delegate = self
        }
        
        if let confirmationViewController = viewController as? STConfirmationPageViewController {
            confirmationViewController.delegate = self
        }
    }
    
    //******************************************************************************************************************
    // MARK: - STContactDetailsFormViewController Delagate
    
    func contactDetailsFormViewController(form: STContactDetailsFormViewController, didCompleteWithContact aContact: STTKContact) {
        self.contact = aContact
    }
    
    //******************************************************************************************************************
    // MARK: - STSelectTreeViewController Delegate
    
    func selectTreeViewController(selectTreeViewController: STSelectTreeViewController, didSelectTreeDescription aTreeDescription: STPKTreeDescription) {
        self.treeDescription = aTreeDescription
    }
    
    //******************************************************************************************************************
    // MARK: - STAddressFormViewController Delegate
    
    func addressFormViewController(form: STAddressFormViewController, didCompleteWithAddress anAddress: STTKStreetAddress) {
        self.address = anAddress
    }
    
    //******************************************************************************************************************
    // MARK: - STConfirmationPageViewController Delegate
    
    func confirmationFormViewController(form: STConfirmationPageViewController, didCompleteWithWufooForm anWufooForm: STTKWufooForm) {
        self.wufooForm = anWufooForm
    }
}
