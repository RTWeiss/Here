//
//  SettingsViewController.swift
//  Fix
//
//  Created by Zackery leman on 4/1/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

   
    
     private let meteor = (UIApplication.sharedApplication().delegate as AppDelegate).meteorClient
    @IBAction func LogOut(sender: UIBarButtonItem) {
        meteor.logout()
        let error = Locksmith.deleteDataForUserAccount(GlobalConstants.singleUserAccount)
        performSegueWithIdentifier(StoryBoard.logoutSegue, sender: self)
    }
    
    private struct StoryBoard {
        static let logoutSegue = "logOut"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
}
}