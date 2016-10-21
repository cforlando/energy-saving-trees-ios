//
//  STConfirmationPageViewController.swift
//  Street Trees
//
//  Created by Pedro Trujillo on 10/17/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//

import UIKit
import StreetTreesTransportKit
import StreetTreesPersistentKit


//**********************************************************************************************************************
// MARK: - Constants

private let STTreeErrorTitle = "Error"
private let STTreeErrorNameMessage = "Tree name has not been passed."

//**********************************************************************************************************************
// MARK: - Enumerations

enum STConfirmationDetailRows
{
    case TreeName
    case Address
    case CityStateZip
    case UserName
    case Phone
    case email
    
    func sectionHeader() -> String?
    {
        switch self
        {
        case .TreeName:
            return "Tree Information"
        case .Address, .CityStateZip:
            return "Location"
        case .UserName, .Phone, .email:
            return "Contact"
        }
    }
}


//**********************************************************************************************************************
// MARK: - DataSource

struct DataSource
{
    
    private let dataSource: [[STConfirmationDetailRows]]
    
    var sections: Int {
        return self.dataSource.count
    }
    
    func itemsForSection(atIndex anIndex: Int) -> Int {
        return self.dataSource[anIndex].count
    }
    
    func item(forRow aRow: Int, inSection aSection: Int) -> STConfirmationDetailRows {
        return self.dataSource[aSection][aRow]
    }
    
    init(dataSource:[[STConfirmationDetailRows]]) {
        self.dataSource = dataSource
    }
}

//**********************************************************************************************************************
// MARK: - Protocol

protocol STConfirmationPageViewControllerDelegate: NSObjectProtocol
{
    func confirmationFormViewController(form: STConfirmationPageViewController, didCompleteWithWufooForm anWufooForm: STTKWufooForm)
}

//**********************************************************************************************************************

class STConfirmationPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TreeDescription, Address, Contact
{
    
    var treeDescription:STPKTreeDescription?
    var address: STTKStreetAddress?
    var contact: STTKContact?
 
    
    var dataSource: DataSource = DataSource(dataSource: [[.TreeName], [.Address, .CityStateZip], [.UserName, .Phone, .email]])
    
    weak var  delegate:STConfirmationPageViewControllerDelegate?

    // MARK: - Table View Methods:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return dataSource.sections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSource.itemsForSection(atIndex: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)

        let kindOfRow = dataSource.item(forRow: indexPath.row, inSection: indexPath.section)
        
        var textLabel:String? = nil
        var imageView:UIImage? = nil
        
        switch kindOfRow
        {
        case .TreeName:
            textLabel = treeDescription?.name ?? "Error retrieving tree name"
            imageView = treeDescription?.image() ?? UIImage(named: "blankMap")
        case .Address:
            textLabel = (address?.streetAddress)!  + " " +  (address?.secondaryAddress)! ?? "Error retrieving address"
        case .CityStateZip:
            textLabel = "\(address?.city), \(address?.state) \(String((address?.zipCode)!))" ?? "Error retrieving location"
        case .UserName:
            textLabel = (contact?.name)! ?? "Error retrieving name"
        case .Phone:
            textLabel = (contact?.phoneNumber)! ?? "Error retrieving phone number"
        case .email:
            textLabel = (contact?.email)! ?? "Error retrieving email"
        }
        
        cell.textLabel?.text = textLabel
        cell.imageView?.image = imageView
       
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.item(forRow: 0, inSection: section).sectionHeader()
    }
    

    // MARK: Action handlers:
    
    @IBAction func confirmButtonItemTouchUpInside(sender: AnyObject)
    {
        
        if confrim()
        {
            let alertConfimationMessage = UIAlertController(title: "Confirmation", message: "Thank You! Your request has been sent", preferredStyle: .Alert)
            let sentImage = UIImage(named: "sent")
            let sentAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            sentAction.setValue(sentImage, forKey: "image")
            alertConfimationMessage.addAction(sentAction)
            self.presentViewController(alertConfimationMessage, animated: true, completion: nil)
        }
    }
    
    //******************************************************************************************************************
    // MARK: - Private Functions
    
    func confrim() -> Bool
    {
        guard let treeName = treeDescription?.name where treeName.isEmpty else
        {
            self.showAlert(STTreeErrorTitle, message: STTreeErrorNameMessage)
            return false
        }
        
        guard let safeContact = self.contact else
        {
            fatalError("Contact has not been passed.")
        }
        
        self.delegate?.confirmationFormViewController(self, didCompleteWithWufooForm: STTKWufooForm(tree: treeName, forContact: safeContact))
        return true
    }

}
