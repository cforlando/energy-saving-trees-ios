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
    var aWufooForm:STTKWufooForm?

    var treeName = "Example Tree"
    var treeImage : UIImage?
    var address = "101 Example Ave"
    var cityStateZip = "Orlando, Fl 32801"
    var name = "Bob Bobington"
    var phone = "407-555-5550"
    var email = "bob@google.com"
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    // MARK: Get information from Wufoo Form
        
        treeName = (aWufooForm?.treeName)!
        //treeImage =  aWufooForm?
        address = (aWufooForm?.contact.address.streetAddress)! + " " + (aWufooForm?.contact.address.secondaryAddress)! //"101 Example Ave"
        cityStateZip = (aWufooForm?.contact.address.city)! + ", " + (aWufooForm?.contact.address.state)! + " " + String((aWufooForm?.contact.address.zipCode)!) //"Orlando, Fl 32801"
        name = (aWufooForm?.contact.name)! //"Bob Bobington"
        phone = (aWufooForm?.contact.phoneNumber)! //"407-555-5550"
        email = (aWufooForm?.contact.email)! //"bob@google.com"
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
    
    // MARK: - Table View Methods 
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("treeInfoCell", forIndexPath: indexPath)
        
        if  indexPath.row == 0
        {
            cell.textLabel?.text = treeName
            //cell.imageView?.image = treeImage
        }
        if  indexPath.row == 1 {
            
            cell.textLabel?.text = "Location:"
        }
        if  indexPath.row == 3 {
            
            cell.textLabel?.text = address
        }
        if  indexPath.row == 4 {
            
            cell.textLabel?.text = cityStateZip
        }
        if  indexPath.row == 5 {
            
            cell.textLabel?.text = "Contact:"
        }
        if  indexPath.row == 6 {
            
            cell.textLabel?.text = name
        }
        if  indexPath.row == 7 {
            
            cell.textLabel?.text = phone
        }
        if  indexPath.row == 8 {
            
            cell.textLabel?.text = email
        }

        
        return cell
    }

}
