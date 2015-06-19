//
//  AppDelegate.swift
//  Here
//
//  Created by Zackery leman on 3/31/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    //Todo: Take most meteor calls off the main  thread
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
       
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name: MeteorClientDidDisconnectNotification, object: nil)
        
  
        Foursquare2.setupFoursquareWithClientId("Z5VHHCGCOEZABPWIZ5C0YHKOUOBRU4RGT3XA50PXRF0OFCJR", secret:"2TU3RFC0ZXYAC2GISP4YIMHAWYTOLU1CH4U1HE1TKJOYMI4K", callbackURL:"https://here123://foursquare");
        //meteorClient.addObserver(self, forKeyPath: "connected", options: NSKeyValueObservingOptions.New, context: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UIViewController
        
                
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = startViewController;
        window?.makeKeyAndVisible()
        
        return true
    }
    

    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /*
    
    func updatePostLimit(limit: Int) {
        
        self.meteorClient.addSubscription("posts", withParameters:[["limit":limit]])
        
    }
    
    func getAllInterestPosts() {
        
        self.meteorClient.addSubscription("interestPosts", withParameters:[[ "$or" : [ [ "_Id": "6S7jSnGWp2WBEmndf" ], [ "_Id": "a5HcnX9WCQ2CPPxmC" ]] ]] )
        
    }

*/
    
}

// MARK: - Global Extensions

//Deals with issue of navigating to a view controller embeded in a navigation view controller
extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController
        } else {
            return self
        }
    }
    
}

// Quick way to get UIColor for a known Hex value
extension UIColor{
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

// MARK: - Typealiases

typealias PingData = [String:AnyObject]
typealias User = AnyObject
typealias Friends = AnyObject


// MARK: - Global Constants
struct GlobalConstants{
    static let singleUserAccount = "singleUserAccount"
}