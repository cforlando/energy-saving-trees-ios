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

//**********************************************************************************************************************
// MARK: - Constants

private let STConstraintMultiplier: CGFloat = 1.0
private let STConstraintDefaultConstant: CGFloat = 0.0
private let STConstraintTopConstant: CGFloat = -0.5
private let STProgressSelectTree: Float = 0.2
private let STProgressAddAddress: Float = 0.4
private let STProgressAddContact: Float = 0.6
private let STProgressConfirm: Float = 0.8

//**********************************************************************************************************************
// MARK: - Class Implementation

class STOrderFormNavigationViewController: UINavigationController, UINavigationControllerDelegate,
TreeDescription, Address, Contact, STContactDetailsFormViewControllerDelegate, STSelectTreeViewControllerDelegate,
STAddressFormViewControllerDelegate {
    
    var address: STTKStreetAddress?
    var contact: STTKContact?
    var treeDescription: STPKTreeDescription?
    var wufooForm: STTKWufooForm?
    
    lazy var progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .Bar)
        progress.tintColor = UIColor.orlandoGreenColor()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.setProgress(STProgressSelectTree, animated: false)
        self.view.addSubview(progress)
        
        return progress
    }()
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.addConstraintsToProgressBar()
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
            userController.emailTextField.text = self.contact?.email
            userController.nameTextField.text = self.contact?.name
            userController.phoneNumberTextField.text = self.contact?.phoneNumber
        }
        
        if let addressViewController = viewController as? STAddressFormViewController {
            addressViewController.delegate = self
            addressViewController.streetAddressTextField.text = self.address?.streetAddress
            addressViewController.streetAddressTwoTextField.text = self.address?.secondaryAddress
            addressViewController.zipCodeTextField.text = self.address?.zipCode.description
        }
        
        if let treeViewController = viewController as? STSelectTreeViewController {
            treeViewController.delegate = self
        }
        
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        self.updateProgress(viewController)
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
    // MARK: - Private functions
    
    func addConstraintsToProgressBar() {
        let navBar = self.navigationBar
        
        var constraint: NSLayoutConstraint
        
        constraint = NSLayoutConstraint(item: self.progressBar, attribute: .Bottom, relatedBy: .Equal, toItem: navBar, attribute: .Bottom, multiplier: STConstraintMultiplier, constant: STConstraintTopConstant)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.progressBar, attribute: .Left, relatedBy: .Equal, toItem: navBar, attribute: .Left, multiplier: STConstraintMultiplier, constant: STConstraintDefaultConstant)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.progressBar, attribute: .Right, relatedBy: .Equal, toItem: navBar, attribute: .Right, multiplier: STConstraintMultiplier, constant: STConstraintDefaultConstant)
        self.view.addConstraint(constraint)
    }
    
    func updateProgress(newViewController: UIViewController) {
        let progress: Float
        
        if newViewController is STSelectTreeViewController {
            progress = STProgressSelectTree
        } else if newViewController is STAddressFormViewController {
            progress = STProgressAddAddress
        } else if newViewController is STContactDetailsFormViewController {
            progress = STProgressAddContact
        } else if newViewController is STConfirmationPageViewController {
            progress = STProgressConfirm
        } else {
            progress = self.progressBar.progress
        }
        
        self.progressBar.setProgress(progress, animated: self.isViewLoaded())
    }
}
