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
    
    var passLong: Double!
    var passLat: Double!
    
    @IBOutlet weak var message: UITextField!
    
    var custom:Bool!
    
    private var justLaunched:Bool = true
    
    private var nearByVenues:[[String:AnyObject]] = []
    
    private var pingCount: String! {
        didSet{
            navigationItem.rightBarButtonItem?.title = "\(pingCount) Pings"
        }
    }
    
    private var rawPing: PingData!
    private var lat: CLLocationDegrees!
    private var long: CLLocationDegrees!
    private var currentAnnotation: MKPointAnnotation!
    private var runOnce:Bool = false
    
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var currentLocation: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private struct StoryBoard {
        static let toFriendsList = "toFriendsList"
        static let settingsPopover = "settingsPopover"
        static let defaultLocation = "Select Location"
        static let locationAnnotation = "Current Location"
    }
    
    var currentPlace: String? {
        set{
            if newValue != nil {
                place.setTitle("\(newValue!) ▽", forState: .Normal)
                // navigationItem.title! = "\(newValue!) ▽"
                updatePingAndMap()
            }
        }
        get {
            return place.titleLabel!.text ?? StoryBoard.defaultLocation
        }
    }
    
    
    // MARK: VC LifeCycle
    
    func viewWillAppear(animated: Bool) () {
         message.text = ""
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        custom = false
        message.hidden = true
        

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        currentPlace = StoryBoard.defaultLocation
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCount", name: "users_added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCount", name: "users_removed", object: nil)
        
        
    }
    
    // MARK: - Update UI
    
    private func updatePingAndMap(){
        if passLat != nil && passLong != nil {
            locationManager.startUpdatingLocation()
             currentLocation.removeAnnotations(currentLocation.annotations)
            
            if  custom != true{
                rawPing = ["lat": passLat, "long": passLong, "location": "\(currentPlace!)"]
            } else {
                rawPing = ["lat": lat, "long": long, "location": "\(currentPlace!)"]
            }
            
            var longitude:CLLocationDegrees
            var latitude:CLLocationDegrees
            
            if  custom  != true{
                print("Indicates not custom")
                longitude =  passLong
                latitude =   passLat
                
            } else {
                print("Indicates  custom")
                longitude =  long
                latitude =   lat
            }
            var latDelta:CLLocationDegrees = 0.001
            var longDelta:CLLocationDegrees = 0.001
            var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var theRegion = MKCoordinateRegionMake(location,theSpan)
             currentLocation.setRegion(theRegion, animated: false)
            
            var theLocationAnnotation = MKPointAnnotation()
            
            theLocationAnnotation.coordinate = location
            theLocationAnnotation.title =  currentPlace ?? "ERROR"
            theLocationAnnotation.subtitle = StoryBoard.locationAnnotation
             currentAnnotation = theLocationAnnotation
             currentLocation.addAnnotation(theLocationAnnotation)
             currentLocation.selectAnnotation(theLocationAnnotation, animated: true)
        }
    }
    
    
    
    private func updateLocButton(){
        if (!runOnce){
            
            let selectedVenueText =  nearByVenues[0]["location"] as! String
             place.titleLabel!.text = "\(selectedVenueText)"
             place.titleLabel!.text =  place.titleLabel!.text! + " ▽"
             runOnce = true
        }
    }
    
    
    //Shows use the input for writing a message
    @IBAction private func longPress(sender: AnyObject) {
        println("Long press")
         message.hidden = false
    }
    
    
    
    
    // MARK: - Location
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error while updating location %@",error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location) {(placemarks, error)-> Void in
            println("\(locations.count)")
            let coor = locations[0] as! CLLocation
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
                let pm = placemarks[0] as! CLPlacemark
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
        
        if  justLaunched {
            let latitude:CLLocationDegrees =  lat
            let longitude:CLLocationDegrees =  long
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
    
    
    
    
    private func loadPlaces(){
        
        let lat = NSNumber(double:  self.lat)
        let long = NSNumber(double:  self.long)
        let limit = NSNumber(int: 20)
        let radius = NSNumber(int: 100)
        
        //Query FourSquare for nearby venues
        Foursquare2.venueSearchNearByLatitude(lat,longitude: long, query: nil, limit: limit, intent: FoursquareIntentType.intentCheckin, radius: radius, categoryId: nil) {(success, venues) in
            
            if (success) {
                
                let venuesObject = ((venues as! [String:AnyObject])["response"] as! [String:AnyObject])["venues"] as! [[String:AnyObject]]
                
                for places in venuesObject {
                    
                    let name = places["name"] as! String
                    
                    let lat =  (places["location"] as! [String:AnyObject])["lat"] as! Double
                    
                    let long =  (places["location"] as! [String:AnyObject])["lng"] as! Double
                    
                     self.nearByVenues.append(["location": name,"lat": lat, "long": long])
                    
                    if   self.nearByVenues.count == 1 {
                         self.rawPing  = ["lat": lat, "long": long, "location": name]
                        
                    }
                     self.updateLocButton()
                    
                }
            } else {
                println("Failure")
                
            }
            
        }
        
    }
    
    // MARK: - Navigation
    
    //Unwind from the popover Segue
    @IBAction func unwind(segue:UIStoryboardSegue){}
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == StoryBoard.settingsPopover {
            if let ctvc = segue.destinationViewController.contentViewController as? CampusTableViewController{
                ctvc.nearByVenues  =  nearByVenues
            }
            
        }
    }
    
}



