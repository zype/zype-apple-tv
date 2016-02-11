//
//  ZypeTokenModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class ZypeTokenModel: NSObject {

    private let kDefaultsKeyAccessToken = "kDefaultsKeyAccessToken"
    private let kDefaultsKeyRefreshToken = "kDefaultsKeyRefreshToken"
    private let kDefaultsKeyExpirationDate = "kDefaultsKeyExpirationDate"
    
    public var refreshToken: String {
        set  {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kDefaultsKeyRefreshToken)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let token = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultsKeyRefreshToken)
            if (token == nil)
            {
                return ""
            }
            return token as! String
        }
    }
    
    public var expirationDate: Int {
            set {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kDefaultsKeyExpirationDate)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            get {
            let date = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultsKeyExpirationDate)
            if (date == nil)
            {
                return 0
            }
            return date as! Int
        }
    }
    
    public var accessToken: String {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kDefaultsKeyAccessToken)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            let token = NSUserDefaults.standardUserDefaults().valueForKey(kDefaultsKeyAccessToken)
            if (token == nil)
            {
                return ""
            }
            return token as! String
        }
    }
    
    override init() {
        super.init()
    }
    
    func reset()
    {
        refreshToken = ""
        accessToken = ""
        expirationDate = 0
    }
    
}
