//
//  STOrderFormNavigationViewController.swift
//  Street Trees
//
//  Created by Tom Marks on 15/10/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

class STOrderFormNavigationViewController: UINavigationController, UINavigationControllerDelegate,
TreeDescription, Address, Contact, STContactDetailsFormViewControllerDelegate, STSelectTreeViewControllerDelegate,
STAddressFormViewControllerDelegate {

    var treeDescription: STPKTreeDescription?
    var address: STTKStreetAddress?
    var contact: STTKContact?
    
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
}
