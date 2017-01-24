//
//  ReplaceSegue.swift
//  Svetliy
//
//  Created by Andrey Kasatkin on 1/20/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import Foundation

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
  
        //make Tab Bar VC as a root view controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
               appDelegate.window?.rootViewController = destination
     
        source.navigationController?.pushViewController(destination, animated: true)
    }
}
