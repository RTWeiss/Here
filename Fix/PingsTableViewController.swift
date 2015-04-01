//
//  pingsTableViewController.swift
//  Here
//
//  Created by Zackery leman on 8/2/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class PingsTableViewController: UITableViewController {
    var experiment:UIViewController!;
    var userInfo:String!;
    var meteor:MeteorClient!;
    var pingList: NSMutableArray = [];
    var preview: [String] = [];
    var theOneThatWasClickedOn:Int!;
    @IBOutlet var pingTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.meteor = appDelegate.meteorClient
        NSLog(self.meteor.collections.description);
       // self.meteor.removeSubscription("users")
       // self.meteor.removeSubscription("userData")
       // self.meteor.addSubscription("userData")
        
    
        if self.meteor.collections["users"] != nil{
            let user = self.meteor.collections["users"] as M13OrderedDictionary;
            NSLog(user.description);
            var emails: NSDictionary = user.objectAtIndex(0) as NSDictionary;
            var emails2 = emails["Pings"]
            if (emails2?.count != 0){
                var emails2: NSMutableArray = emails["Pings"] as NSMutableArray;
                self.pingList = emails2
                for test in emails2{
                    
                    NSLog( test.description)
                    var sender: NSString = test["userName"] as NSString;
                    var location: NSString = test["location"] as NSString;
                    let preview = "\(sender) @ \(location)"
                    self.preview.append(preview)
                }
            }

        } else{
            self.meteor.addSubscription("users");
             self.meteor.addSubscription("userData");
            let thread = NSThread(target:self, selector:"lala", object:nil)
            thread.start()
        }
        self.navigationItem.title = "Current Pings";
        self.pingTable.registerClass(BFPaperTableViewCell.self, forCellReuseIdentifier: "BFPaperCell")
        let  clearAllButton :UIBarButtonItem = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: "clearAll")
        self.navigationItem.rightBarButtonItem = clearAllButton;
    }
    
    func lala(){
        NSThread.sleepForTimeInterval(1)
        let user = self.meteor.collections["users"] as M13OrderedDictionary;
        NSLog(user.description);
        var emails: NSDictionary = user.objectAtIndex(0) as NSDictionary;
        var emails2 = emails["Pings"]
        if (emails2?.count != 0){
            var emails2: NSMutableArray = emails["Pings"] as NSMutableArray;
            self.pingList = emails2
            for test in emails2{
                
                NSLog( test.description)
                var sender: NSString = test["userName"] as NSString;
                var location: NSString = test["location"] as NSString;
                let preview = "\(sender) @ \(location)"
                self.preview.append(preview)
            }
        }

    }

    
    func clearAll(){
        NSLog("Clearing ALl")
        self.meteor.callMethodName("removeAllPings", parameters:nil, responseCallback:{( response,  error) in
            if error != nil {
                NSLog("failed")
                return;
            }
            NSLog("sucess")
            
        });
        
        pingTable.reloadData();
        self.navigationController?.popViewControllerAnimated(true);
        
        
    }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.preview.count;
    }
    

        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
             let cell = tableView.dequeueReusableCellWithIdentifier("BFPaperCell", forIndexPath: indexPath) as BFPaperTableViewCell
   // let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 3;
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        //cell.textLabel.text =  self.preview[indexPath.row]
        let author  = "2 hours ago"
        cell.textLabel?.text = "\(self.preview[indexPath.row]) \n \(author)";
        cell.textLabel?.textAlignment = NSTextAlignment.Center;
        cell.textLabel?.textColor = UIColor.blackColor();
        cell.textLabel?.font = UIFont.systemFontOfSize(14);
        cell.tapCircleColor = UIColor.paperColorAmber()
        cell.rippleFromTapLocation = true;
        cell.backgroundFadeColor = UIColor.paperColorBlue();
        cell.textLabel?.backgroundColor = UIColor.clearColor();
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let it = self.pingList[indexPath.row]
        let ity = it["location"]
        println("You selected location: \(ity)!")
        self.theOneThatWasClickedOn = indexPath.row
        // self.userInfo = items[indexPath.row]
        // self.tempPlace = "\(items[indexPath.row])"
        self.performSegueWithIdentifier("pingsDetail", sender: self)
    }
    

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 70;
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            self.preview.removeAtIndex(indexPath.row);
            pingTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let dict = self.pingList[indexPath.row]
            var parameters = ["\(self.meteor.userId)"]
            let it = dict["_id"]
            parameters.append("\(it)")
            
            println(parameters.description)
            self.meteor.callMethodName("removePing", parameters:parameters, responseCallback:{( response,  error) in
                if (error != nil) {
                    NSLog("failed")
                    return;
                }
                NSLog("sucess")
                
            });
            
            
            NSLog("Deleting row")
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "pingsDetail") {
            var svc = segue!.destinationViewController as PingDetail;
            //svc.toPass = self.userInfo;
            svc.toPassPing = self.pingList[theOneThatWasClickedOn] as NSDictionary
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
