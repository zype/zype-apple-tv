//
//  SubscriptionModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/26/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//


public class SubscriptionModel: NSObject {

    private(set) public var ID: String = ""
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init()
    }
}
