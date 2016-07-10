//
//  STInitialViewController.swift
//  Street Trees
//
//  Created by Tom Marks on 5/07/2016.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import StreetTreesPersistentKit

class STInitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        STPKCoreData.sharedInstance.setupCoreData({ (coreDataStack) in
            STPKCoreData.sharedInstance.createUser({ (user, anError) in
                NSOperationQueue.mainQueue().addOperationWithBlock({ 
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    UIApplication.sharedApplication().keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
                })
            })
        }) { (error) in
            //TODO: handle error
            exit(1)
        }
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
