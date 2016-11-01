//
//  STConfirmationPageViewController.swift
//  Street Trees
//
//  Created by Pedro Trujillo on 10/17/16.
//  Copyright © 2016 Code for Orlando. All rights reserved.
//


import StreetTreesTransportKit
import StreetTreesPersistentKit
import UIKit


//**********************************************************************************************************************
// MARK: - Constants:

private let STTreeErrorTitle = "Error"
private let STTreeErrorNameMessage = "Tree name has not been passed."

//**********************************************************************************************************************
// MARK: - Enumerations:

enum STConfirmationDetailRows
{
    case TreeName
    case Address
    case CityStateZip
    case UserName
    case Phone
    case Email
    
    func sectionHeader() -> String
    {
        switch self
        {
        case .TreeName:
            return "Tree Information"
        case .Address, .CityStateZip:
            return "Location"
        case .UserName, .Phone, .Email:
            return "Contact"
        }
    }
}


//**********************************************************************************************************************
// MARK: - DataSource:

struct DataSource
{
    
    private let dataSource: [[STConfirmationDetailRows]]
    
    var sections: Int {
        return self.dataSource.count
    }
    
    func itemsForSection(atIndex anIndex: Int) -> Int {
        return self.dataSource[anIndex].count
    }
    
    func item(forIndexPath anIndexPath:NSIndexPath) -> STConfirmationDetailRows {
        return self.dataSource[anIndexPath.section][anIndexPath.row]
    }
    
    init(dataSource:[[STConfirmationDetailRows]]) {
        self.dataSource = dataSource
    }
}

//**********************************************************************************************************************
// MARK: - Protocol:

protocol STConfirmationPageViewControllerDelegate: NSObjectProtocol
{
    func confirmationFormViewController(form: STConfirmationPageViewController, didCompleteWithWufooForm anWufooForm: STTKWufooForm)
}

//**********************************************************************************************************************

class STConfirmationPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TreeDescription, Address, Contact
{
    
    var address: STTKStreetAddress?
    var contact: STTKContact?
    var dataSource: DataSource = DataSource(dataSource: [[.TreeName], [.Address, .CityStateZip], [.UserName, .Phone, .Email]])
    weak var  delegate:STConfirmationPageViewControllerDelegate?
    var treeDescription:STPKTreeDescription?
 
    
//**********************************************************************************************************************
// MARK: - Table View Methods:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.dataSource.sections
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataSource.itemsForSection(atIndex: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
        let kindOfRow = self.dataSource.item(forIndexPath: indexPath)
        
        var imageView:UIImage? = nil
        var textLabel:String? = nil
        
        switch kindOfRow
        {
        case .TreeName:
            textLabel = treeDescription?.name ?? "Error retrieving tree name"
            imageView = treeDescription?.image() ?? UIImage(named: "blankMap")
            cell.imageView?.image = imageView
        case .Address:
            let anAddress = address?.streetAddress ?? "No address specified"
            let anAddress2 = address?.secondaryAddress ?? ""
            textLabel =  "\(anAddress) \(anAddress2)"
        case .CityStateZip:
            let aCity = address?.city ?? "No city specified"
            let aState = address?.state ?? "No state specified"
            let aZip = address?.state ?? "No zip specified"
            textLabel = "\(aCity), \(aState) \(String(aZip))"
        case .UserName:
            textLabel = contact?.name ?? "Error retrieving name"
        case .Phone:
            textLabel = contact?.phoneNumber ?? "Error retrieving phone number"
        case .Email:
            textLabel = contact?.email ?? "Error retrieving email"
        }
        
        cell.textLabel?.text = textLabel
       
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource.item(forIndexPath: NSIndexPath(forRow: 0, inSection: section)).sectionHeader()
    }
    
//**********************************************************************************************************************
// MARK: - Actions:
    
    @IBAction func confirmButtonItemTouchUpInside(sender: AnyObject)
    {
        
        if self.confirm()
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
// MARK: - Private Functions:
    
    func confirm() -> Bool
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
