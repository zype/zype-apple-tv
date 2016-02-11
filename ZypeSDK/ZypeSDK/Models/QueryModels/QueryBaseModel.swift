//
//  QueryBaseModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class QueryBaseModel: NSObject  {

    init(page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        super.init()
        self.page = page
        self.perPage = perPage
    }
    
    public var page: Int = kApiFirstPage
    public var perPage: Int = 0
    
}
