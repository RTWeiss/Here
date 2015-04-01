//
//  PingDetail.swift
//  Here
//
//  Created by Zackery leman on 8/3/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit
import MapKit

class PingDetailViewController: UIViewController, MKMapViewDelegate{
    
    
    @IBOutlet weak var message: UILabel!
    

    var ping: PingData!
    
    @IBOutlet weak var pingLocation: MKMapView!
    @IBOutlet weak var placeLabel: UILabel!
    
    // MARK: VC LifeCycle
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        println("Delete the ping")
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var latitude  = self.ping["lat"] as CLLocationDegrees
        var longitude  = self.ping["long"] as CLLocationDegrees
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
        navigationItem.title = self.ping["userName"] as? String
        self.placeLabel.text = self.ping["location"] as? String
        self.message.text = self.ping["message"] as? String
    }


    
}
