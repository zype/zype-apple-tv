//
//  ZobjectTypeModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/22/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class ZobjectTypeModel: BaseModel {
    
    private(set) public var keywords = Array<String>()
    private(set) public var createdAt: NSDate?
    private(set) public var updatedAt: NSDate?
    private(set) public var descriptionString = ""
    private(set) public var videosEnabled = true
    private(set) public var zobjectCount = 0
    private(set) public var siteIdString = ""
    private(set) public var zobjectAttributes: Array<AnyObject>?

    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        do
        {
            let keywords = fromJson[kJSON_Keywords]
            if (keywords != nil)
            {
                self.keywords = keywords as! Array<String>
            }
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            self.descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
            self.videosEnabled = try SSUtils.boolFromDictionary(fromJson, key: kJSONVideosEnabled)
            self.zobjectCount = try SSUtils.intagerFromDictionary(fromJson, key: kJSONZobjectCount)
            self.siteIdString = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)
            self.zobjectAttributes = fromJson[kJSONZobjectAttributes] as? Array<AnyObject>
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectTypeModel")
        }
    }
    
    public func getZobjects(loadedSince: NSDate = NSDate(), completion:(zobjects: Array<ZobjectModel>?, error: NSError?) -> Void)
    {
        let zobjects = self.userData["zobjects"]
        if zobjects != nil
        {
            if(loadedSince.compare(self.userData["zobjects_date"] as! NSDate) == NSComparisonResult.OrderedAscending)
            {
                completion(zobjects: zobjects as? Array<ZobjectModel>, error: nil)
                return
            }
        }
        ZypeSDK.sharedInstance.getZobjects(QueryZobjectsModel(objectType: self), completion: { (objects, error) -> Void in
            self.userData["zobjects"] = objects
            self.userData["zobjects_date"] = NSDate()
            completion(zobjects: objects, error: error)
        })
    }
    
}
