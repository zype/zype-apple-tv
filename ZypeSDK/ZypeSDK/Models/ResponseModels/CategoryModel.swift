//
//  CategoryModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class CategoryModel : BaseModel {
    
    public let keywords: Array<String>
    private(set) public var valuesArray: Array<CategoryValueModel>? = nil
        
    init(fromJson: Dictionary<String, AnyObject>)
    {
        keywords = CategoryModel.getKeywords(fromJson[kJSON_Keywords] as? Array<AnyObject>)
        super.init(json: fromJson)
        valuesArray = CategoryModel.getValues(fromJson[kJSONValues] as? Array<AnyObject>, parent: self)
    }
    
    public func valueByID(ID: String) -> CategoryValueModel?
    {
        let filteredArray = self.valuesArray!.filter({(item) -> Bool in return item.ID == ID})
        return filteredArray.first
    }
    
    private static func getKeywords(json: Array<AnyObject>?) -> Array<String>
    {
        if (json == nil)
        {
            return Array()
        }
        return json as! Array<String>
    }
    
    private static func getValues(json: Array<AnyObject>?, parent: CategoryModel) -> Array<CategoryValueModel>
    {
        var labels = Array<CategoryValueModel>()
        if (json != nil)
        {
            for value in json!
            {
                let title = value as! String
                labels.append(CategoryValueModel(name: title, parent: parent))
            }
        }
        return labels
    }

}
    

