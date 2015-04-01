//
//  CampusTableViewController.swift
//  Here
//
//  Created by Zackery leman on 8/1/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit
import CoreLocation
class CampusTableViewController: UITableViewController {
    
    var nearByVenues:[Dictionary<String,Any>]!;
    var tempPlace:NSString!;
    var newWordField: UITextField!
    @IBOutlet weak var currentDisplayLocation: UILabel!
    @IBOutlet var campusTableView: UITableView!
    @IBOutlet weak var coordinates: UILabel!
    
    var selected: Int!;
    var items:[Dictionary<String,Any>] = [["location":"Afam","lat":43.9065640, "long": -69.9636130],["location":"Baxter","lat":43.9064296, "long": -69.9625026],["location":"Brunswick Apartments","lat":43.90372897121463, "long":-69.96564025059342 ],["location":"Smith Union","lat":43.9082345, "long":-69.9603166 ],["location":"West","lat":43.9056711, "long":-69.9617176 ],["location":"Farley FieldHouse","lat":43.9028226, "long":-69.9598669 ],["location":"Osher","lat":43.9057581, "long":-69.9611919 ],["location":"West","lat":43.9056711, "long":-69.9617176 ]]
    
    //["location":"Druckenmiller","lat":, "long": ]["location":"Burnett","lat":, "long": ],["location":"Helmreich","lat":, "long": ],["location":"Howell","lat":, "long": ],["location":"Ladd","lat":, "long": ],["location":"MacMillan","lat":, "long": ],["location":"Quinby","lat":, "long": ],["location":"Reed","lat":, "long": ],["location":"Brunswick Apartment's Quad","lat":, "long": ],["location":"Hyde","lat":, "long": ],//,["location":"Appleton","lat":, "long": ],["location":"Coleman","lat":, "long": ],["location":"Winthrop","lat":, "long": ],["location":"Moore","lat":, "long": ],["location":"Maine","lat":, "long": ]]
    //["location":"Crack","lat":12, "long":12 ]
    
    
    //  var self.nearByVenues = ["Afam", "Baxter","Burnett","Druckenmiller", "Farley FieldHouse","Helmreich","Howell","Ladd","MacMillan","Quinby","Reed", "Smith Union","Crack", "Quad","Brunswick Apartment's Quad","Hyde", "Osher","West","Appleton","Coleman","Winthrop","Moore", "Maine"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinates.text = "Coordinates"
        self.navigationItem.title = "Select Current Location";
        self.navigationItem.hidesBackButton = true;
        self.campusTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
   
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.self.nearByVenues.count + 1;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
       
        //var dic:Dictionary<String,Any>
    
        if indexPath.row == 0 {
            var dictEntry: String =  "Custom"
             cell.textLabel?.text = dictEntry;
            
        } else{
            
            var dic = self.nearByVenues[indexPath.row - 1]
            var dictEntry: String = dic["location"] as String
             cell.textLabel?.text = dictEntry;
        }
        
      //  var dic = self.nearByVenues[indexPath.row]
       // var dictEntry: String = dic["location"] as String
      //  cell.textLabel.text = dictEntry;
        cell.textLabel?.textAlignment = NSTextAlignment.Center;
        cell.textLabel?.textColor = UIColor.whiteColor();
        cell.textLabel?.font = UIFont.systemFontOfSize(20);
        let temp:CGFloat =  (CGFloat(indexPath.row))/20
        var increment:CGFloat = 0.3 + temp
        let rowLimit = 10
        if indexPath.row < rowLimit {
            cell.backgroundColor = UIColor(red: 0.5, green: increment, blue: 0.9, alpha: 1.0);
        } else{
            let tempRed:CGFloat =  (CGFloat(indexPath.row-rowLimit))/20
            var redIncrement:CGFloat = 0.5 - tempRed
            cell.backgroundColor = UIColor(red: redIncrement, green: CGFloat(CGFloat(rowLimit)/20+0.3)-tempRed, blue: 0.9, alpha: 1.0);
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.row == 0 {
            self.selected = -1
            add()
        } else {
        
        
        var dic = self.nearByVenues[indexPath.row - 1]
        var dictEntry: String = dic["location"] as String
        println("You selected location: \(dictEntry)")
        self.tempPlace = "\(dictEntry)"
        self.tempPlace = "\(dictEntry)"
        
        self.selected = indexPath.row - 1
        self.currentDisplayLocation.text =  self.tempPlace
        self.performSegueWithIdentifier("returnIt", sender: self)
            
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "returnIt") {

            var svc = segue!.destinationViewController as MainViewController;
            svc.toPass2 = self.tempPlace;
            svc.custom = true
            if self.selected != -1 {
            svc.custom = false
            var dic = self.nearByVenues[self.selected]
            var lat: Double = dic["lat"] as Double
            var long:Double = dic["long"] as Double
            svc.passLong         = long
            svc.passLat = lat
            }
            
        }
    }
    
    
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Place"
        self.newWordField = textField
    }
    
    func wordEntered(alert: UIAlertAction!){
        var textView2 = self.newWordField.text
        if textView2 != ""{
            println("You selected location: \(textView2)")
            self.tempPlace = "\(textView2)"
            self.currentDisplayLocation.text =  self.tempPlace
 
        }
        self.performSegueWithIdentifier("returnIt", sender: self)
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        println("User click Cancel button")
        
    }
    
    func add(){
        var alert = UIAlertController(title: "Custom Location", message: "Enter your current location", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:wordEntered))
        self.presentViewController(alert, animated: true, completion: {
        
        })
        
    }
    
    
    
    
}
