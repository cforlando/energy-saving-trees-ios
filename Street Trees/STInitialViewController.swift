//
//  STInitialViewController.swift
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

import StreetTreesFoundationKit
import StreetTreesPersistentKit
import UIKit

//**********************************************************************************************************************
// MARK: - Constants

private let STBackgroundLayerImageMotionMovement: CGFloat = 40.0
private let STTopLayerImageMotionMovement: CGFloat = 20.0

//**********************************************************************************************************************
// MARK: - Class Implementation

class STInitialViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var heartImageView: UIImageView!
    
    //******************************************************************************************************************
    // MARK: - Class Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        STPKCoreData.sharedInstance.setupCoreData({ (coreDataStack) in
            STPKCoreData.sharedInstance.createUser({ (user, anError) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                STPKCoreData.sharedInstance.refreshAll { (anError) in
                    OperationQueue.main.addOperation({
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
                    })
                }
            })
        }) { (error) in
            //TODO: handle error
            exit(1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addMotionEffects()
    }
    
    //******************************************************************************************************************
    // MARK: - Internal Functions
    
    func addMotionEffects() {
        self.add(motionToView: self.heartImageView, movement: STTopLayerImageMotionMovement)
        self.add(motionToView: self.codeImageView, movement: STTopLayerImageMotionMovement)
        self.add(motionToView: self.cityImageView, movement: STTopLayerImageMotionMovement)
        self.add(motionToView: self.backgroundImageView, movement: STBackgroundLayerImageMotionMovement)
    }
}
