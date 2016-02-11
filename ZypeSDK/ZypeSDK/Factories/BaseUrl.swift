//
//  BaseUrl.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

class BaseUrl: NSObject {

    weak var controller:ZypeRESTController?
    
    init(restController: ZypeRESTController)
    {
        super.init()
        controller = restController
    }

}
