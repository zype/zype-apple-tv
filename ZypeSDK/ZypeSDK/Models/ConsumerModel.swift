//
//  ConsumerModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/14/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class ConsumerModel: NSObject {

    private (set) public var ID:String = ""
    private (set) public var emailString:String = ""
    private (set) public var nameString:String = ""
    private (set) internal var passwordString: String = ""
    
    public init(name: String = "", email: String = "", password: String = "")
    {
        super.init()
        self.nameString = name
        self.emailString = email
        self.passwordString = password
    }
    
    public var isLoggedIn: Bool {
        return ID.isEmpty == false
    }
    
    func setData(consumerId: String, email: String, name: String)
    {
        ID = consumerId
        emailString = email
        nameString = name
    }
    
    func reset()
    {
        ID = ""
        emailString = ""
        nameString = ""
    }
    
}
