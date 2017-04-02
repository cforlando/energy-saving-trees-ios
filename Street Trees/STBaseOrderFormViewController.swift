//
//  STBaseOrderFormViewController.swift
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
import StreetTreesFoundationKit
import StreetTreesTransportKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STKeyboardVerticalSpacingPadding: CGFloat = 20.0

//**********************************************************************************************************************
// MARK: - Class Implementation

class STBaseOrderFormViewController: UIViewController, TextFieldAdjustment, Address, Contact, TreeDescription {
    
    @IBOutlet weak var stackViewTopLayoutConstraint: NSLayoutConstraint? {
        didSet {
            self.defaultTopConstraintConstant = stackViewTopLayoutConstraint?.constant ?? 0
        }
    }
    
    var activeTextField: UITextField?
    var address: STTKStreetAddress?
    var contact: STTKContact?
    var treeDescription: STPKTreeDescription?
    
    fileprivate var defaultTopConstraintConstant: CGFloat = 0.0
    
    //******************************************************************************************************************
    // MARK: - ViewController Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] (notification: Notification) in
            guard let strongSelf = self else { return }
            guard let textField = strongSelf.activeTextField else { return }
            guard let frameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
            
            let keyboardFrame = frameValue.cgRectValue
            
            if strongSelf.activeTextFieldIntersects(rect: keyboardFrame) {
                let yDiff = strongSelf.intersectAmount(betweenView: textField, andRect: keyboardFrame).y
                strongSelf.stackViewTopLayoutConstraint?.constant -= yDiff + STKeyboardVerticalSpacingPadding
                strongSelf.animateLayoutChanges()
            } else {
                strongSelf.resetTextFieldPositioning()
            }
        }
        
        notificationCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] (notification: Notification) in
            guard let strongSelf = self else { return }
            strongSelf.resetTextFieldPositioning()
        }
        
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    fileprivate func animateLayoutChanges() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    fileprivate func resetTextFieldPositioning() {
        self.stackViewTopLayoutConstraint?.constant = self.defaultTopConstraintConstant
        self.animateLayoutChanges()
    }

}
