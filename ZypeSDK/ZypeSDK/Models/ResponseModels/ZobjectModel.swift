//
//  ZobjectModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/22/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class ZobjectModel: BaseModel {

    private(set) public var json: Dictionary<String, AnyObject>
    
    public var descriptionString: String
    {
       return self.getStringValue(kJSONDescription)
    }
    public var keywords:Array<String>
    {
        return self.json[kJSONKeywords] as! Array<String>
    }
    public var active:Bool
    {
        return self.getBoolValue(kJSONActive)
    }
    private(set) public var createdAt: NSDate?
    private(set) public var updatedAt: NSDate?
    public var siteID:String
    {
        return self.getStringValue(kJSONSiteId)
    }
    public var videoIds: Array<String>?
    {
        return self.json[kJSONVideoIds] as? Array<String>
    }
    public var zobjectTypeId: String
    {
        return self.getStringValue(kJSONZobjectTypeId)
    }
    public var zobjectTypeTitle: String
    {
        return self.getStringValue(kJSONZobjectTypeTitle)
    }

    private(set) public var pictures = Array<ContentModel>()
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        self.json = fromJson
        super.init(json: fromJson)
        do
        {
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            let pictures = self.json[kJSONPictures]
            if pictures != nil
            {
                for value in pictures as! Array<AnyObject>
                {
                    self.pictures.append(ContentModel(json: value as! Dictionary<String, AnyObject>))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
    }
    
    public func getStringValue(key: String) -> String
    {
        do
        {
            return try SSUtils.stringFromDictionary(json, key: key)
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
        return ""
    }
    
    public func getBoolValue(key: String) -> Bool
    {
        do
        {
            return try SSUtils.boolFromDictionary(json, key: key)
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
        return false
    }
    
}
