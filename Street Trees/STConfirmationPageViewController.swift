//
//  STConfirmationPageViewController.swift
//  Street Trees
//
//  Created by Pedro Trujillo on 10/17/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import StreetTreesTransportKit

class STConfirmationPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    
    var aTree:STTKStreetTree?
    var anAddress: STTKStreetAddress?
    var aContact: STTKContact?
    
    var treeName = "Example Tree"
    var treeImage : UIImage?
    var address = "101 Example Ave"
    var cityStateZip = "Orlando, Fl 32801"
    var name = "Bob Bobington"
    var phone = "407-555-5550"
    var email = "bob@google.com"
    
    var aWufooForm:STTKWufooForm?

    

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    // MARK: Get information from Wufoo Form:
        
        treeName = (aTree?.name)!
        //treeImage =  aTree.
        address = (anAddress?.streetAddress)!  + " " +  (anAddress?.secondaryAddress)!
        cityStateZip = "\(anAddress?.city), \(anAddress?.state) \(String((anAddress?.zipCode)!))"
        name = (aContact?.name)!
        phone = (aContact?.phoneNumber)!
        email = (aContact?.email)!
        
        aWufooForm = STTKWufooForm(tree: treeName, forContact: aContact!)
    }

    override func didReceiveMemoryWarning()
    {
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
    
    // MARK: - Table View Methods:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)

        
        if  indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("treeInfoCell", forIndexPath: indexPath)

            cell.textLabel?.text = treeName
            //cell.imageView?.image = treeImage
        }
        if  indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath)

            cell.textLabel?.text = "Location:"
        }
        if  indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("addressCell", forIndexPath: indexPath)

            cell.textLabel?.text = address
        }
        if  indexPath.row == 4 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("cityStateZipCell", forIndexPath: indexPath)

            cell.textLabel?.text = cityStateZip
        }
        if  indexPath.row == 5 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
            
            cell.textLabel?.text = "Contact:"
        }
        if  indexPath.row == 6 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("userNameCell", forIndexPath: indexPath)

            
            cell.textLabel?.text = name
        }
        if  indexPath.row == 7 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneCell", forIndexPath: indexPath)

            
            cell.textLabel?.text = phone
        }
        if  indexPath.row == 8 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("emailCell", forIndexPath: indexPath)
            
            cell.textLabel?.text = email
        }

        
        return cell
    }
    
    // MARK: Action handlers:
    
    @IBAction func sendInformationTouchUpInside(sender: AnyObject)
    {

    }
    

}
