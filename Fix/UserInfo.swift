//
//  SavedTweets.swift
//  twitterHash
//
//  Created by Zackery leman on 3/26/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Foundation


class UserInfo {
    private struct Const {
        static let userIdKey = "UserInfo.userName"
        static let passKey = "UserInfo.password"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var userName: String? {
        get { return defaults.objectForKey(Const.userIdKey) as? String }
        set { defaults.setObject(newValue, forKey: Const.userIdKey) }
    }
    
    var password: String? {
        get { return defaults.objectForKey(Const.passKey)  as? String }
        set { defaults.setObject(newValue, forKey: Const.passKey) }
    }
    

    

    
    
}


