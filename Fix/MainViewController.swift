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
    var initialLoad = true
    let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    var passLong: Double!
    var passLat: Double!
    
    @IBOutlet weak var message: UITextField!
    
    var custom:Bool!
    private var justLaunched:Bool = true
    var nearByVenues:[[String:AnyObject]] = []
    
    var pingCount: String! {
        didSet{
            navigationItem.rightBarButtonItem?.title = "\(pingCount) Pings"
        }
    }
    
    var  rawPing: PingData!
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var currentAnnotation: MKPointAnnotation!
    private var runOnce:Bool = false
    
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var currentLocation: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private struct StoryBoard {
        static let toFriendsList = "toFriendsList"
        static let settingsPopover = "settingsPopover"
        static let defaultLocation = "Select Location"
    }
    
     var currentPlace: String? {
        set{
            if newValue != nil {
                place.setTitle("\(newValue!) ▽", forState: .Normal)
                self.navigationItem.title! = "\(newValue!) ▽"
                if !initialLoad {
                    updatePingAndMap()
                    initialLoad = false
                }
            }
        }
        get {
            return place.titleLabel!.text ?? StoryBoard.defaultLocation
        }
    }
    
    
    func updatePingAndMap(){
        locationManager.startUpdatingLocation()
        self.currentLocation.removeAnnotations(currentLocation.annotations)
        
        if self.custom != true{
            rawPing = ["lat": passLat, "long": passLong, "location": "\(currentPlace!)"]
        } else {
            rawPing = ["lat": lat, "long": long, "location": "\(currentPlace!)"]
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
        theLocationAnnotation.title =  currentPlace ?? "ERROR"
        theLocationAnnotation.subtitle = "Current Location"
        self.currentAnnotation = theLocationAnnotation
        self.currentLocation.addAnnotation(theLocationAnnotation)
        self.currentLocation.selectAnnotation(theLocationAnnotation, animated: true)
    }
    

    func viewWillAppear(animated: Bool) () {
        self.message.text = ""
        updateCount()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        custom = false
        message.hidden = true

        if let user = meteor.collections["users"] as? M13OrderedDictionary {
        println(user.description)
        
        let userObject = user.objectAtIndex(0) as [String:AnyObject]
        let pingArray = userObject["Pings"] as [AnyObject]
        pingCount = "\(pingArray.count)"
            
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        currentPlace = StoryBoard.defaultLocation
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCount", name: "users_added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCount", name: "users_removed", object: nil)


    }

    
    func updateCount(){
        let user = self.meteor.collections["users"] as M13OrderedDictionary
        let userObject = user.objectAtIndex(0) as [String:AnyObject]
        let pingArray = userObject["Pings"] as [AnyObject]
        pingCount = "\(pingArray.count)"
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error while updating location %@",error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location) {(placemarks, error)->Void in
            println("\(locations.count)")
            let coor = locations[0] as CLLocation
            let latitude = coor.coordinate.latitude
            let longitude = coor.coordinate.longitude
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
                NSLog("Problem with the data received from geocoder") 
            }
        }
    }
    
    
    
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()

        loadPlaces()
        
        if self.justLaunched {
            let latitude:CLLocationDegrees = self.lat
            let longitude:CLLocationDegrees = self.long
            let latDelta:CLLocationDegrees = 0.001
            let longDelta:CLLocationDegrees = 0.001
            let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let theRegion = MKCoordinateRegionMake(location,theSpan)
            currentLocation.setRegion(theRegion, animated: false)
            let theLocationAnnotation = MKPointAnnotation()
            theLocationAnnotation.coordinate = location
            theLocationAnnotation.title = currentPlace
            theLocationAnnotation.subtitle = "Current Location"
            
            currentLocation.addAnnotation(theLocationAnnotation)
            justLaunched = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == StoryBoard.toFriendsList {
            if let flvc = segue.destinationViewController as? FriendsListViewController{
                rawPing["message"] = self.message.text
                flvc.rawPing = self.rawPing
            }
        }
        
        if segue.identifier == StoryBoard.settingsPopover {
            if let ctvc = segue.destinationViewController as? CampusTableViewController{
                ctvc.nearByVenues  = self.nearByVenues
            }
            
        }
    }
    
    
    
    func loadPlaces(){
        
        let lat = NSNumber(double: self.lat)
        let long = NSNumber(double: self.long)
        let limit = NSNumber(int: 20)
        let radius = NSNumber(int: 100)
        
        //Query FourSquare for nearby venues
        Foursquare2.venueSearchNearByLatitude(lat,longitude: long, query: nil, limit: limit, intent: FoursquareIntentType.intentCheckin, radius: radius, categoryId: nil) {(success, venues) in
            
            if (success) {
                
                let venuesObject = ((venues as [String:AnyObject])["response"] as [String:AnyObject])["venues"] as [[String:AnyObject]]
                
                for places in venuesObject {
                    
                    let name = places["name"] as String

                    let dic2 =  places["location"] as [String:AnyObject]
                    
                    let latString =  dic2["lat"] as Double
                    
                    let lat = latString + 0
                    
                    let longString =  dic2["lng"] as Double
                    
                    let long = longString + 0
   
                    self.nearByVenues.append(["location": name,"lat": lat, "long": long])
                    
                    if  self.nearByVenues.count == 1 {
                         self.rawPing  = ["lat": lat, "long": long, "location": name]
                       
                    }
                    self.updateLocButton()
                    
                }
            } else {
                println("Failure")
                
            }

        }
        
    }
    
    func updateLocButton(){
        if (!self.runOnce){
            
            let selectedVenueText = self.nearByVenues[0]["location"] as String
            self.place.titleLabel!.text = "\(selectedVenueText)"
            self.place.titleLabel!.text = self.place.titleLabel!.text! + " ▽"
            self.runOnce = true
        }
    }
    
    //Shows use the input for writing a message
    @IBAction func longPress(sender: AnyObject) {
        println("Long press")
        self.message.hidden = false
    }
    
    
    //Unwind from the popover Segue
    @IBAction func unwind(segue:UIStoryboardSegue){}
}



