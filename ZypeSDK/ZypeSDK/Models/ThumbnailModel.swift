//
//  ThumbnailModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class ThumbnailModel: NSObject {
    
    public let height: Int
    public let width: Int
    public let imageURL: String
    public let name: String
    
    init(height: Int, width: Int, url:String, name: String) {
        self.height = height
        self.width = width
        self.imageURL = url
        self.name = name
        super.init()
    }

}
