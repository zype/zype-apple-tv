//
//  QueryVideosModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class QueryVideosModel: QueryBaseModel {

    public var categoryKey: String = ""
    public var categoryValue: String = ""
    public var exceptCategoryKey: String = ""
    public var exceptCategoryValue: String = ""
    public var searchString: String = ""
    public var keyword: String = ""
    public var active: Bool = true
    public var status: String = ""
    public var type: String = ""
    public var videoID: String = ""
    public var exceptVideoID: String = ""
    public var zObjectID: String = ""
    public var exceptZObjectID: String = ""
    public var createdDate: NSDate? = nil
    public var publishedDate: NSDate? = nil
    public var dpt: Bool = true
//    public var sortBy: String = ""
    public var onAir: Bool = false
    public var sort: String?
    public var ascending: Bool = false

    public init(categoryValue: CategoryValueModel? = nil,
        exceptCategoryValue: CategoryValueModel? = nil,
        searchString: String = "",
        page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        super.init(page: page, perPage: perPage)
        if (categoryValue != nil)
        {
            self.categoryKey = categoryValue!.parent!.titleString
            self.categoryValue = categoryValue!.titleString
        }
        if (exceptCategoryValue != nil)
        {
            self.exceptCategoryKey = exceptCategoryValue!.parent!.titleString
            self.exceptCategoryValue = exceptCategoryValue!.titleString
        }
        self.searchString = searchString
    }

}
