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
            return ""
        case .Address, .CityStateZip:
            return "Location:"
        case .UserName, .Phone, .Email:
            return "Contact:"
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let kindOfRow = self.dataSource.item(forIndexPath: indexPath)

        switch kindOfRow
        {
        case .TreeName:
            return 100
        default:
            return 22
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath)
        let kindOfRow = self.dataSource.item(forIndexPath: indexPath)
        
        var aImage:UIImage? = nil
        var textLabel:String? = nil
        
        cell.textLabel?.font = UIFont.systemFontOfSize(20)
        
        switch kindOfRow
        {
        case .TreeName:
            aImage = treeDescription?.image() ?? UIImage(named: "blankMap")
            textLabel = treeDescription?.name ?? "Error retrieving tree name"
            
            cell.imageView?.image = aImage
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.font = UIFont.systemFontOfSize(24)
            cell.textLabel?.numberOfLines = 3
            
        case .Address:
            let anAddress = address?.streetAddress ?? "No address specified"
            let anAddress2 = address?.secondaryAddress ?? ""
            textLabel =  "\(anAddress) \(anAddress2)"
            
        case .CityStateZip:
            let aCity = address?.city ?? "No city specified"
            print(aCity)
            let aState = address?.state ?? "No state specified"
            let aZip = "\(address?.zipCode ?? 0)"
            textLabel = "\(aCity), \(aState) \(aZip)"
            
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 80.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.dataSource.item(forIndexPath: NSIndexPath(forRow: 0, inSection: section)).sectionHeader()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return UIView(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let aHeader:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        aHeader.textLabel?.backgroundColor = UIColor.clearColor()
        aHeader.textLabel?.font = UIFont.systemFontOfSize(22)
        aHeader.textLabel?.textColor = UIColor.lightGrayColor()
        aHeader.textLabel?.text? = aHeader.textLabel?.text?.capitalizedString ?? ""
        aHeader.tintColor = UIColor.clearColor()
    }
    
    
    
//**********************************************************************************************************************
// MARK: - Actions:
    
    @IBAction func confirmButtonItemTouchUpInside(sender: AnyObject)
    {
        
        if self.confirm()
        {
            

            let alertConfimationMessage = UIAlertController(title: "Confirmation", message: "Thank You! Your request has been sent.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default)
            {
                UIAlertAction in

                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let rootVC = mainStoryBoard.instantiateInitialViewController()
                UIApplication.sharedApplication().keyWindow?.rootViewController = rootVC
            }
            alertConfimationMessage.addAction(okAction)
            self.presentViewController(alertConfimationMessage, animated: true, completion: nil)
        }
    }
    
//******************************************************************************************************************
// MARK: - Private Functions:
    
 
    func confirm() -> Bool
    {
        
        guard let treeName = treeDescription?.name else
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
