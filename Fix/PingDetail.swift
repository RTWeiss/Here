//
//  PingDetail.swift
//  Here
//
//  Created by Zackery leman on 8/3/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit
import MapKit

class PingDetail: UIViewController, MKMapViewDelegate{
    
    
    @IBOutlet weak var message: UILabel!
    
    var toPass: NSString!;
    var toPassPing: NSDictionary!;
    var ping: NSDictionary!;
    @IBOutlet weak var pingLocation: MKMapView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBAction func deletePing(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    @IBAction func destroyPing(segue:UIStoryboardSegue){
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ping = self.toPassPing
        var latitude:CLLocationDegrees = self.ping["lat"] as CLLocationDegrees
        var longitude:CLLocationDegrees = self.ping["long"] as CLLocationDegrees
        var latDelta:CLLocationDegrees = 0.001
        var longDelta:CLLocationDegrees = 0.001
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var theRegion = MKCoordinateRegionMake(location,theSpan)
        self.pingLocation.setRegion(theRegion, animated: false)
        var theLocationAnnotation = MKPointAnnotation()
        theLocationAnnotation.coordinate = location
        theLocationAnnotation.title = self.ping["location"] as String
        theLocationAnnotation.subtitle = self.ping["location"] as String
        self.pingLocation.addAnnotation(theLocationAnnotation)
        self.userLabel.text = self.ping["userName"] as? String
        self.placeLabel.text = self.ping["location"] as? String
        self.message.text = self.ping["message"] as? String
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
