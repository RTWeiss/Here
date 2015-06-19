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
    
    var ping: PingData!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var pingLocation: MKMapView!
    @IBOutlet weak var placeLabel: UILabel!
    

    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        println("Delete the ping")
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let latitude  = ping["lat"] as! CLLocationDegrees
        let longitude  = ping["long"] as! CLLocationDegrees
        let latDelta:CLLocationDegrees = 0.001
        let longDelta:CLLocationDegrees = 0.001
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let theRegion = MKCoordinateRegionMake(location,theSpan)
        pingLocation.setRegion(theRegion, animated: false)
        
        let theLocationAnnotation = MKPointAnnotation()
        theLocationAnnotation.coordinate = location
        theLocationAnnotation.title = ping["location"] as! String
        theLocationAnnotation.subtitle = ping["location"]as! String
        
        pingLocation.addAnnotation(theLocationAnnotation)
        navigationItem.title = ping["userName"] as? String
        placeLabel.text = ping["location"] as? String
        message.text = ping["message"] as? String
    }


    
}
