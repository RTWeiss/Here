//
//  tab.swift
//  Here
//
//  Created by zack leman on 8/7/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class FriendsListViewController: UITableViewController {
    
    
    
    private let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    var friendsList:[Friends]!
    private var selected: [String:Int] = [:]
    private var usersToPing: [String] = []
    var rawPing: PingData!
    private var newWordField: UITextField!
    
    
    struct StoryBoard {
        static let friendsBFPaperCell = "friendsPaperCell"
    }
    
    
    // MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = meteor.collections["users"] as? M13OrderedDictionary{
            println(user.description)
            friendsList = user.objectAtIndex(0)["FriendsList"] as [Friends]
            
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.friendsBFPaperCell, forIndexPath: indexPath) as BFPaperTableViewCell
        
        
        
        let cellText = (friendsList[indexPath.row] as NSDictionary).valueForKey("userId")
        cell.textLabel?.text = "\(cellText!)"
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        tableView.allowsMultipleSelection = true
        cell.tapCircleColor = UIColor.paperColorAmber()
        cell.rippleFromTapLocation = true
        cell.backgroundFadeColor = UIColor.paperColorBlue()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as BFPaperTableViewCell
        
        if  selected["\(indexPath.row)"] != nil {
            selected.removeValueForKey("\(indexPath.row)")
            cell.backgroundColor = UIColor.clearColor()
        } else {
            cell.backgroundColor = UIColor.paperColorAmberA100()
            selected["\(indexPath.row)"] = indexPath.row
        }
    }
    
    
    
    // MARK: Meteor Calls
    
    @IBAction func send(sender: UIBarButtonItem) {
        if selected.count != 0{
            
            //Get rid of NS dictionary and use map instead
            for number in ((selected as NSDictionary).allValues as [Int]) {
                usersToPing.append(friendsList[number]["userId"] as String)
            }
            
            add()
            println("Sending the pings")
            
        } else {
            var alert = UIAlertController(title: "No friends Selected", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Select Friends", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    private func add(){
        
        if let user = meteor.collections["users"] as? M13OrderedDictionary {
            
            rawPing["_id"] = BSONIdGenerator.generate()
            rawPing["sender"] = meteor.userId
            rawPing["userName"] = user.objectAtIndex(0)["userName"]
            
            let parameters = [usersToPing, rawPing] as NSArray
            
            meteor.callMethodName("addPing", parameters: parameters, responseCallback:{( response,  error) in
                if (error != nil) {
                    println("failed")
                    return
                }
                println("sucess")
            })
            
            navigationController?.popViewControllerAnimated(true)
            
        }
        
    }
    
    
    
}


