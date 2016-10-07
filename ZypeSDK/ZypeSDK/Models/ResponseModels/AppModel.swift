//
//  AppSettingsModel.swift
//  ZypeSDK
//
//  Created by Khurshid Fayzullaev on 3/20/16.
//  Copyright © 2016 Ilya Sorokin. All rights reserved.
//

import UIKit

public class AppModel : NSObject {
    
    private (set) public var ID = ""
    private (set) public var site_id = ""
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init()
        do
        {
            self.ID = try SSUtils.stringFromDictionary(fromJson, key: kJSON_Id)
            self.site_id = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)        }
        catch
        {
            ZypeLog.error("Exception: AppModel")
        }
    }
    
}