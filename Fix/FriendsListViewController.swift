//
//  tab.swift
//  Here
//
//  Created by zack leman on 8/7/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class FriendsListViewController: UITableViewController {
    var nameArray:[NSString] = []
    var meteor:MeteorClient! 
    var FriendsList:NSArray! 
    var selected: [String:Int] = [:] 
    var usersToPing: [String]! 
    var  rawPing: NSMutableDictionary! 
    var newWordField: UITextField! 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Friends"
        self.tableView.registerClass(BFPaperTableViewCell.self, forCellReuseIdentifier: "BFPaperCell")
        let  SendButton :UIBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: "send")
        self.navigationItem.rightBarButtonItem = SendButton 
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.meteor = appDelegate.meteorClient
           let user = self.meteor.collections["users"] as M13OrderedDictionary 
        NSLog(user.description) 
        var dict: NSDictionary = user.objectAtIndex(0) as NSDictionary 
        var dictA: NSArray = ["FriendsList"] as NSArray 
        var emails: NSDictionary = user.objectAtIndex(0) as NSDictionary 
        var emails2: NSArray = emails["FriendsList"] as NSArray 
        self.FriendsList = emails2
        for test in emails2{
            var fargo: NSString = test["userId"] as NSString 
        }
    }
    
    func send(){
        if (self.selected.count != 0){
            var newDict: NSDictionary =    self.selected as NSDictionary
            let numbersSelected: [Int] = newDict.allValues as [Int]
            self.usersToPing = []
            for number:Int in numbersSelected {
                let ir:NSDictionary = self.FriendsList[number] as NSDictionary
                let ir2:String = ir["userId"] as String
                self.usersToPing.append(ir2)
            }
            add()
            println("Sending the pings")
            
        } else {
            var alert = UIAlertController(title: "No friends Selected", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Select Friends", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        return self.FriendsList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BFPaperCell", forIndexPath: indexPath) as BFPaperTableViewCell
        
        //cell.textLabel.text =  people[indexPath.row]
        
        let ity: NSDictionary = self.FriendsList[indexPath.row] as NSDictionary
        let bity = ity.valueForKey("userId")
        cell.textLabel?.text = "\(bity)"
        cell.textLabel?.textAlignment = NSTextAlignment.Center 
        cell.textLabel?.textColor = UIColor.blackColor() 
        cell.textLabel?.font = UIFont.systemFontOfSize(14) 
        self.tableView.allowsMultipleSelection = true 
        cell.tapCircleColor = UIColor.paperColorAmber()
        cell.rippleFromTapLocation = true 
        cell.backgroundFadeColor = UIColor.paperColorBlue() 
        cell.textLabel?.backgroundColor = UIColor.clearColor() 
        return cell
    }
    
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as BFPaperTableViewCell  
        
        if let unwrappedValue = self.selected["\(indexPath.row)"] {
            self.selected.removeValueForKey("\(indexPath.row)")
            cell.backgroundColor = UIColor.clearColor()
        } else {
            cell.backgroundColor = UIColor.paperColorAmberA100()
            self.selected["\(indexPath.row)"] = indexPath.row
        }
        
        //self.tableView.reloadData()
    }
    
    
    
   
    
    func add(){
        
        var uid: NSString = BSONIdGenerator.generate() 
        self.rawPing["sender"] = self.meteor.userId
        self.rawPing["_id"] = uid
           let user = self.meteor.collections["users"] as M13OrderedDictionary 
        var dict: NSDictionary = user.objectAtIndex(0) as NSDictionary 
        var userName: String = dict["userName"] as String 
        self.rawPing["userName"] = userName
        var parameters: NSArray = [self.usersToPing, self.rawPing] 
        self.meteor.callMethodName("addPing", parameters:parameters, responseCallback:{( response,  error) in
            if (error != nil) {
                NSLog("failed") 
                return 
            }
            NSLog("sucess") 
        }) 
        
        self.navigationController?.popViewControllerAnimated(true) 
        
 
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
}


