//
//  QueryZobjectsModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class QueryZobjectsModel: QueryBaseModel {

    public var zobjectType = ""
    public var keywords = ""
    
    public init (objectType: ZobjectTypeModel? = nil)
    {
        super.init()
        if objectType != nil
        {
            self.zobjectType = objectType!.titleString
        }
    }
    
}
