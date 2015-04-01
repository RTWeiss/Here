//
//  PingsTableViewController.swift
//  Here
//
//  Created by Zackery leman on 8/2/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit


class PingsTableViewController: UITableViewController {
    var experiment:UIViewController!
    private  var userInfo:String!
    private  let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    var pingList:[PingData]?
    private  var preview: [String] = []
    
    
    //StoryBoard Constants
    private  struct StoryBoard {
        static let pingsDetail = "pingsDetailCell"
        static let pingsDetailSegue = "toPingsDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.meteor.removeSubscription("users")
        // self.meteor.removeSubscription("userData")
        // self.meteor.addSubscription("userData")
        
        
        if  let users = self.meteor.collections["users"] as? M13OrderedDictionary {
            let user = users.objectAtIndex(0) as [String:User]
            let pings = user["Pings"] as [PingData]
            if pings.count != 0 {
                pingList = pings
                for ping in pings{
                    let sender = ping["userName"] as? String ?? "DefaultUserName"
                    let location = ping["location"] as String
                    let preview = "\(sender) @ \(location)"
                    self.preview.append(preview)
                }
            }
            
        } else{
            self.meteor.addSubscription("users")
            self.meteor.addSubscription("userData")
            //May need to wait on subscriptions
        }
        self.navigationItem.title = "Current Pings"
        
        let  clearAllButton :UIBarButtonItem = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: "clearAll")
        self.navigationItem.rightBarButtonItem = clearAllButton
    }
    
    
    
    func clearAll(){
        NSLog("Clearing ALl")
        self.meteor.callMethodName("removeAllPings", parameters:nil, responseCallback:{( response,  error) in
            if error != nil {
                NSLog("failed")
                return
            }
            NSLog("sucess")
            
        })
        
        tableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
        
        
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.preview.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.pingsDetail, forIndexPath: indexPath) as BFPaperTableViewCellWithPing
        
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        
        let author  = "2 hours ago"
        cell.textLabel?.text = "\(self.preview[indexPath.row]) \n \(author)"
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        cell.tapCircleColor = UIColor.paperColorAmber()
        cell.rippleFromTapLocation = true
        cell.backgroundFadeColor = UIColor.paperColorBlue()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.ping = pingList![indexPath.row]
        return cell
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            self.preview.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if let dict = self.pingList?[indexPath.row]{
                var parameters = ["\(self.meteor.userId)"]
                let it = dict["_id"]
                parameters.append("\(it)")
                
                
                println(parameters.description)
                
                self.meteor.callMethodName("removePing", parameters:parameters){( response,  error) in
                    if (error != nil) {
                        NSLog("failed")
                        return
                    }
                    NSLog("sucess")
                    
                }
                
                NSLog("Deleting row")
            }
        }
    }
    
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoard.pingsDetailSegue {
            if let pdvc = segue.destinationViewController.contentViewController as? PingDetailViewController{
                if let cell = sender as? BFPaperTableViewCellWithPing {
                    if let ping = cell.ping  {
                        pdvc.ping = ping
                    }
                }
                
            }
        }
        
    }
    
}
