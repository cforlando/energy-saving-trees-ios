//
//  TreeApplicationViewController.swift
//  Street Trees
//
//  Created by Joshua Shroyer on 6/4/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit

class TreeApplicationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // start listening for notifications for moving content out of the way of the keyboard and not obscuring it. Yay for nice things!
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TreeApplicationViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TreeApplicationViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    // finally, the deinitializer is necessary for cleanup
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // methods used for responding to the keyboard and moving content out of the way
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        // take the height of the keyboard, shift the content up by that amount
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {return}
        let keyboardFrame = value.CGRectValue()
        // 20 is some randomly picked value? most likely just to add a bit of padding from any UI at the bottom to the top of the keyboard. Some space is nice.
        // The ternary operator at the end is used to determine if our keyboard should be moving up or down this amount.
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }

    // To dismiss the keyboard
    @IBAction func hideKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


