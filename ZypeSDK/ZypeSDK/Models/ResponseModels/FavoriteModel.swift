//
//  FavoriteModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/15/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class FavoriteModel : NSObject {

    private (set) public var ID = ""
    private (set) public var objectID = ""
    
    init(json: Dictionary<String, AnyObject>)
    {
        super.init()
        do
        {
            self.ID = try SSUtils.stringFromDictionary(json, key: kJSON_Id)
            self.objectID = try SSUtils.stringFromDictionary(json, key: kJSONVideoId)
        }
        catch
        {
            ZypeLog.error("Exception: FavoriteModel")
        }
    }
    
}
