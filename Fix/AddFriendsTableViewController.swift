//
//  AddFriendsTableViewController.swift
//  Here
//
//  Created by zack leman on 8/7/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit
import AddressBook
class AddFriendsTableViewController: UITableViewController {
    
    @IBOutlet var contactsToAdd: UITableView!
    
    private var addressBook: ABAddressBookRef?
    private var nameArray: [String] = []
    private let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    var FriendsList:[Friends]!
    private var newWordField: UITextField!
    @IBOutlet var friendListTable: UITableView!
    
   private struct StoryBoard {
        static let AdressBookBFPaperCell = "AdressBookBFPaperCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getContactsFromAddressBook()
        
        if let user = meteor.collections["users"] as? M13OrderedDictionary {
            println(user.description)
            FriendsList = user.objectAtIndex(0)["FriendsList"] as [Friends]
        }
        
        
    }
       // MARK: - Prompt
    
    @IBAction func add(sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "Search for Friend", message: "Enter User Name", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:wordEntered))
        presentViewController(alert, animated: true) {}
        
    }
    
    func configurationTextField(textField: UITextField!){
        println("configurat hire the TextField")
        // add the text field and make the result global
        textField.placeholder = "Username"
        self.newWordField = textField
    }
    
    func wordEntered(alert: UIAlertAction!){
        var textView2 = self.newWordField.text
        if textView2 != ""{
            
            let parameters = [textView2, meteor.userId]
            
            self.meteor.callMethodName("verifyUser", parameters:parameters) {( response,  error) in
                if (error != nil) {
                    println("Failed to verify user: \(error.description)")

                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                println("Sucess at verifying user")
                
                let alert = UIAlertController(title: "Friend Added", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        println("User click Cancel button")
        // println(self.textField.text)
    }
    
    
    
    
    // MARK: - TableView Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.AdressBookBFPaperCell, forIndexPath: indexPath) as BFPaperTableViewCell
        
        cell.textLabel?.text = nameArray[indexPath.row]
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        self.contactsToAdd.allowsMultipleSelection = true
        cell.tapCircleColor = UIColor.paperColorAmber()
        cell.rippleFromTapLocation = true
        cell.backgroundFadeColor = UIColor.paperColorBlue()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as BFPaperTableViewCell
        var parameters = [self.nameArray[indexPath.row],"sfgargsdth"]
        
        self.meteor.callMethodName("verifyUser", parameters:parameters, responseCallback:{(response,  error) in
            if (error != nil) {
                //  NSLog("User does not exist")
                var alert = UIAlertController(title: "User is not yet on Here", message: "Would you like to invite them?", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            NSLog("User exists")
            
        })
        
    }
    
    // MARK: Address Book Methods
    
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func getContactsFromAddressBook() {
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            println("requesting access...")
            var errorRef: Unmanaged<CFError>? = nil
            addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    self.getContactNames()
                }
                else {
                    println("error")
                }
            })
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            println("access denied")
        }
        else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            println("access granted")
            self.getContactNames()
        }
    }
    
    func getContactNames() {
        var numbersArray:[String] = []
        var errorRef: Unmanaged<CFError>?
        
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        let contactList = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [ABRecordRef]
        println("records in the array \(contactList.count)")
        
        for record in contactList {
            let contactPerson = record as ABRecordRef
            let contactName = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
            println ("contactName \(contactName)")
            nameArray.append(contactName)
            var multi: ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeRetainedValue()
            for ( var j:CFIndex = 0;  j < ABMultiValueGetCount(multi);  j++) {
                let  phone = ABMultiValueCopyValueAtIndex(multi, j).takeRetainedValue() as String
                numbersArray.append(phone)
                println(phone)
            }
        }
        
    }
    
}

