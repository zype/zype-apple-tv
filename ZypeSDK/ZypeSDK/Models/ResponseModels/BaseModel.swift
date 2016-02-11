//
//  BaseModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/11/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class BaseModel : NSObject  {
        
    private(set) public var titleString: String = ""
    private(set) public var ID: String = ""
    
    var userData = Dictionary<String, AnyObject>()
    
    init(json: Dictionary<String, AnyObject>)
    {
        super.init()
        do
        {
            self.ID = try SSUtils.stringFromDictionary(json, key: kJSON_Id)
            self.titleString = try SSUtils.stringFromDictionary(json, key: kJSONTitle)
        }
        catch _
        {
            ZypeLog.error("Exception: BaseModel")
        }
    }
    
    init(json: Dictionary<String, AnyObject>, title: String)
    {
        super.init()
        self.titleString = title
        do
        {
            self.ID = try SSUtils.stringFromDictionary(json, key: kJSON_Id)
        }
        catch _
        {
            ZypeLog.error("Exception: BaseModel")
        }
    }
    
    public init(ID: String, title: String)
    {
        super.init()
        self.ID = ID
        self.titleString = title
    }
  
}

public func == (lhs: BaseModel, rhs: BaseModel) -> Bool
{
    return lhs.ID == rhs.ID
}

public func <=(lhs: BaseModel, rhs: BaseModel) -> Bool
{
    return lhs.ID <= rhs.ID
}

public func >(lhs: BaseModel, rhs: BaseModel) -> Bool
{
    return lhs.ID > rhs.ID
}

public func >=(lhs: BaseModel, rhs: BaseModel) -> Bool
{
    return lhs.ID >= rhs.ID
}