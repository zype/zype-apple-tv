//
//  ContentModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 11/3/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class ContentModel: BaseModel {
    
    private(set) public var contentType = ""
    private(set) public var url = ""
    
    override init(json: Dictionary<String, AnyObject>) {
        super.init(json: json)
        do
        {
            self.contentType = try SSUtils.stringFromDictionary(json, key: kJSONContentType)
            self.url = try SSUtils.stringFromDictionary(json, key: kJSONUrl)
        }
        catch _
        {
            ZypeLog.error("Exception: ContentModel")
        }
    }

}
