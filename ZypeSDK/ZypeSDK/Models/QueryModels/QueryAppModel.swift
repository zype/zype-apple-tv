//
//  QueryAppSettingsModel.swift
//  ZypeSDK
//
//  Created by Khurshid Fayzullaev on 3/20/16.
//  Copyright © 2016 Ilya Sorokin. All rights reserved.
//

import UIKit

public class QueryAppModel: QueryBaseModel {
    
    public var appID = ""
    
    public init(app: AppModel? = nil)
    {
        if app != nil
        {
            self.appID = app!.ID
        }
    }
    
}