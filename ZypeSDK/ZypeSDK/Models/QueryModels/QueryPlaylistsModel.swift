//
//  QueryPlaylistsModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class QueryPlaylistsModel: QueryBaseModel {
    
    public var categoryKey: String = ""
    public var categoryValue: String = ""
    public var active: Bool = true
    public var keyword: String = ""
    
    public init(category: CategoryValueModel? = nil,
        active: Bool = true,
        keyword: String = "")
    {
        super.init()
        if (category != nil)
        {
            self.categoryKey = category!.parent!.titleString
            self.categoryValue = category!.titleString
        }
        self.active = active
        self.keyword = keyword
    }
    
}
