//
//  StartViewController.swift
//  Here
//
//  Created by Zackery leman on 8/2/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    var meteor:MeteorClient!;
    var passLong: Double!;
    var passLat: Double!;
    
    
    @IBOutlet weak var message: UITextField!
    
    var custom:Bool!
    var justLaunched:Bool = true
    var nearByVenues:[Dictionary<String,Any>] = [];
    var pingCount: String! {
        didSet{
            
        }
    }
    var  rawPing: NSMutableDictionary!;
    var lat: CLLocationDegrees!;
    var long: CLLocationDegrees!;
    var  currentAnnotation: MKPointAnnotation!;
    
    
    var toPass:String!;
    var toPass2:String?
    var runOnce:Bool = false
    

    var settingsPopover: UIPopoverController!;

    
    @IBOutlet weak var currentLocation: MKMapView!
    
    let locationManager = CLLocationManager()
    
    private struct StoryBoard {
        static let toFriendsList = "toFriendsList"
        static let settingsPopover = "settingsPopover"
    }

    @IBAction func selected(segue:UIStoryboardSegue){
        if toPass2 != nil {
            self.place.titleLabel!.text = toPass2
            self.place.titleLabel!.text = self.place.titleLabel!.text! + " ▽"
            locationManager.startUpdatingLocation()
            self.currentLocation.removeAnnotations(currentLocation.annotations)
            
            
            if self.custom != true{
                let dict:NSDictionary = ["lat": self.passLat, "long": self.passLong, "location": "\(self.toPass2!)"]
                self.rawPing = dict.mutableCopy() as NSMutableDictionary
            } else {
                
                let dict:NSDictionary = ["lat": self.lat, "long": self.long, "location": "\(self.toPass2!)"]
                self.rawPing = dict.mutableCopy() as NSMutableDictionary
                
            }
            
            
        }
        var longitude:CLLocationDegrees
        var latitude:CLLocationDegrees
        if self.custom  != true{
            print("Indicates not custom")
            longitude = self.passLong
            latitude =  self.passLat
            
        } else {
            print("Indicates  custom")
            longitude = self.long
            latitude =  self.lat
        }
        var latDelta:CLLocationDegrees = 0.001
        var longDelta:CLLocationDegrees = 0.001
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var theRegion = MKCoordinateRegionMake(location,theSpan)
        self.currentLocation.setRegion(theRegion, animated: false)
        
        var theLocationAnnotation = MKPointAnnotation()
        
        theLocationAnnotation.coordinate = location
        theLocationAnnotation.title = toPass2
        theLocationAnnotation.subtitle = "Current Location"
        self.currentAnnotation = theLocationAnnotation
        self.currentLocation.addAnnotation(theLocationAnnotation)
        self.currentLocation.selectAnnotation(theLocationAnnotation, animated: true)
        
    }
    func viewDidAppear(animated: Bool) () {
        //self.navigationController.navigationBarHidden = false;//JUSTCHANGED
        self.message.text = ""
    }
    
    func updateCount(){
            let user = self.meteor.collections["users"] as M13OrderedDictionary;
        var dict: NSDictionary = user.objectAtIndex(0) as NSDictionary;
        var dictA: NSArray = dict["currentInterests"] as NSArray;
        self.pingCount = "\(dictA.count)"
    }
    func seg(){
        self.performSegueWithIdentifier("toPings", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.custom = false
        self.message.hidden = true
        println("Why reload")
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.meteor = appDelegate.meteorClient
        let user = self.meteor.collections["users"] as M13OrderedDictionary //as NSArray;
        NSLog(user.description);
        var dict: NSDictionary = user.objectAtIndex(0) as NSDictionary;
        var dictA: NSArray = dict["Pings"] as NSArray;
        self.pingCount = "\(dictA.count)"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        if (toPass2 != nil) {
            self.place.titleLabel!.text = toPass2
            if self.place.titleLabel!.text == "Here ▽" {
            }
        }
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.title = self.toPass;
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error while updating location %@",error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            NSLog("%i",locations.count)
            var  coor: CLLocation = locations[0] as CLLocation
            var latitude = coor.coordinate.latitude
            var longitude = coor.coordinate.longitude
            NSLog(longitude.description)
            NSLog(latitude.description)
            self.long = longitude
            self.lat = latitude
            
            
            if (error != nil) {
                println("Reverse geocoder failed with error %@", error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                NSLog("Problem with the data received from geocoder");
            }
        })
    }
    
    
    
    
    func displayLocationInfo(placemark: CLPlacemark) {
       // if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
          /*  println(placemark.locality ? placemark.locality : "")
            println(placemark.postalCode ? placemark.postalCode : "")
            println(placemark.administrativeArea ? placemark.administrativeArea : "")
            println(placemark.country ? placemark.country : "")*/
            loadPlaces()
            
            if self.justLaunched {
                var latitude:CLLocationDegrees = self.lat
                var longitude:CLLocationDegrees = self.long
                var latDelta:CLLocationDegrees = 0.001
                var longDelta:CLLocationDegrees = 0.001
                var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                var theRegion = MKCoordinateRegionMake(location,theSpan)
                self.currentLocation.setRegion(theRegion, animated: false)
                var theLocationAnnotation = MKPointAnnotation()
                theLocationAnnotation.coordinate = location
                theLocationAnnotation.title = self.toPass2
                theLocationAnnotation.subtitle = "Current Location"
                
                self.currentLocation.addAnnotation(theLocationAnnotation)
                
                self.justLaunched = false
            }
    }
    
    
    
    
    func dismissPopover  (){
        self.settingsPopover.dismissPopoverAnimated(true);
    }
    

    @IBOutlet weak var place: UIButton!

 
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == StoryBoard.toFriendsList {
            var svc = segue!.destinationViewController as friendsList;
            self.rawPing["message"] = self.message.text
            svc.rawPing = self.rawPing
        }
        
        if segue.identifier == StoryBoard.settingsPopover {
            var svc = segue!.destinationViewController as CampusTableViewController;
            svc.nearByVenues  = self.nearByVenues
            
        }
    }
    
    func loadPlaces(){
        var lat: NSNumber = NSNumber(double: self.lat)
        var long: NSNumber = NSNumber(double: self.long)
        var limit: NSNumber = NSNumber(int: 20)
        var radius: NSNumber = NSNumber(int: 100)
        
        Foursquare2.venueSearchNearByLatitude(lat,longitude: long, query: nil, limit: limit, intent: FoursquareIntentType.intentCheckin, radius: radius, categoryId: nil, callback: {(success, venues) in
            
            if (success) {
                var dic:NSDictionary = venues as NSDictionary;
                
                //  println(dic.description)
                
                var dic2:NSDictionary =  dic["response"] as NSDictionary
                //  println(dic2.description)
                
                var dic3:NSArray =  dic2["venues"] as NSArray
                
                
                // println(dic3.description)
                for places in dic3 {
                    var  name:String = places["name"] as String
                    //  println(name)
                    var dic4:NSDictionary =  places["location"] as NSDictionary
                    
                    
                    
                    let latString:Double =  dic4["lat"] as Double
                    let lat:Double = latString + 0
                    let longString:Double =  dic4["lng"] as Double
                    let long:Double = longString + 0
                    
                    
                    let it:Dictionary<String,Any>  = ["location": name,"lat": lat, "long": long]
                    if  self.nearByVenues.count == 0{
                        
                    }
                    self.nearByVenues.append(it)
                    if  self.nearByVenues.count == 1{
                        let dict:NSDictionary = ["lat": lat, "long": long, "location": name]
                        self.rawPing = dict.mutableCopy() as NSMutableDictionary
                    }
                    self.updateLocButton()
                    
                }
                
                
            } else {
                println("Failure")
                
            }
            
            
            
        })
        
    }
    
    func updateLocButton(){
        if (!self.runOnce){
            let what = self.nearByVenues[0]
            self.place.titleLabel!.text = what["location"] as String
             self.place.titleLabel!.text = self.place.titleLabel!.text! + " ▽"
            self.runOnce = true
        }
    }
    
    @IBAction func longPress(sender: AnyObject) {
        
        println("Long press")
        self.message.hidden = false
    }
}
