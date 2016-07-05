//
//  UIViewControllerExtension.swift
//  Street Trees
//
//  Created by Tom Marks on 5/07/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        self.presentViewController(alertViewController, animated: true, completion: nil)
    }
}