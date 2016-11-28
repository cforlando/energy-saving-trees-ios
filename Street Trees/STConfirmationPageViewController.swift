//
//  STConfirmationPageViewController.swift
//  Street Trees
//
//  Created by Pedro Trujillo on 10/17/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import StreetTreesPersistentKit
import StreetTreesTransportKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants:

private let ST4InchHeight: CGFloat = 568.0
private let STAlertDismissButtonTitle = "OK"
private let STContactErrorMessage = "Contact information has not been passed."
private let STOrderCompleteMessage = "Thank You! Your request has been sent."
private let STOrderCompleteTitle = "Order Complete"
private let STProgressComplete: Float = 1.0
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
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIScreen.mainScreen().nativeBounds.height / UIScreen.mainScreen().nativeScale < ST4InchHeight {
            self.contactLabel.hidden = true
            self.deliveryLabel.hidden = true
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
    
    @IBAction func confirmButtonItemTouchUpInside(sender: AnyObject) {
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.startAnimating()
        
        let barButton = UIBarButtonItem(customView: activityView)
        self.navigationItem.rightBarButtonItem = barButton
        
        if let navigationController = self.navigationController as? STOrderFormNavigationViewController {
            navigationController.progressBar.setProgress(STProgressComplete, animated: true)
        }
        
        self.alertController = UIAlertController(title: STSendingFormTitle, message: STSendingFormMessage, preferredStyle: .Alert)
        
        self.presentViewController(self.alertController!, animated: true) {
            NSThread.sleepForTimeInterval(2)
            self.submitForm()
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions

    func submitForm() {
        guard let treeName = treeDescription?.name else {
            self.showAlert(STTreeErrorTitle, message: STTreeErrorNameMessage)
            return
        }
        
        guard let safeContact = self.contact else {
            self.showAlert(STTreeErrorTitle, message: STContactErrorMessage)
            return
        }
        
        let wufooRequest = STTKWufooRequest()
        let wufooForm = STTKWufooForm(tree: treeName, forContact: safeContact)
        
        wufooRequest.execute(wufooForm) { [weak self] (error: NSError?) in
            guard let safeSelf = self else { return }
            
            let okAction = UIAlertAction(title: STAlertDismissButtonTitle, style: .Default) { [weak self] _ in
                self?.dismissViewControllerAnimated(true, completion: nil)
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
