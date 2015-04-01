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
    
    var addressBook: ABAddressBookRef?
    var nameArray:[NSString] = []
    var meteor:MeteorClient! 
    var FriendsList:NSArray! 
    var selected: [String:Int] = ["123456789" : 123456789] 
    var newWordField: UITextField! 
    @IBOutlet var friendListTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        self.navigationItem.title = "Add Friends From Contacts"
        self.contactsToAdd.registerClass(BFPaperTableViewCell.self, forCellReuseIdentifier: "BFPaperCell")
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.meteor = appDelegate.meteorClient
        NSLog(self.meteor.collections.description) 
            let user = self.meteor.collections["users"] as M13OrderedDictionary 
        NSLog(user.description) 
        var dict: NSDictionary = user.objectAtIndex(0) as NSDictionary 
        var dictA: NSArray = ["FriendsList"] as NSArray 
        self.FriendsList = dictA
        let  addButton :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "add")
        self.navigationItem.rightBarButtonItem = addButton 
        
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

            var parameters: NSArray = [ textView2,self.meteor.userId] 
            self.meteor.callMethodName("verifyUser", parameters:parameters) {( response,  error) in
                if (error != nil) {
                    NSLog("failed at verifying user") 
                    println(error.description)
                    var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return 
                }
                NSLog("sucess at verifying user") 
                var alert = UIAlertController(title: "Friend Added", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                
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
    
    
    func add(){
        var alert = UIAlertController(title: "Search for Friend", message: "Enter User Name", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:wordEntered))
        self.presentViewController(alert, animated: true, completion: {
            println("completion block")
        })

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.nameArray.count // self.FriendsList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BFPaperCell", forIndexPath: indexPath) as BFPaperTableViewCell
        cell.textLabel?.text = self.nameArray[indexPath.row]
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
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
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
    
    
    
    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func test() {
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
        var numbersArray:[NSString] = []
        var errorRef: Unmanaged<CFError>?
        addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        println("records in the array \(contactList.count)")
        
        for record:ABRecordRef in contactList {
            var contactPerson: ABRecordRef = record
            var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
            println ("contactName \(contactName)")
            self.nameArray.append(contactName)
            var multi: ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeRetainedValue() 
            for ( var j:CFIndex = 0;  j < ABMultiValueGetCount(multi);  j++) {
                var  phone:NSString = ABMultiValueCopyValueAtIndex(multi, j).takeRetainedValue() as NSString 
                numbersArray.append(phone)
                println(phone)
            }
        }
        
    }
    
}

