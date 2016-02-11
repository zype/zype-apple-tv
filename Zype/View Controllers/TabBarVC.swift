//
//  TabBarVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/29/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.items![0].title = localized("Home.TabTitle")
    self.tabBar.items![1].title = localized("Search.TabTitle")
    self.tabBar.items![2].title = localized("Favorites.TabTitle")
    let background = UIImageView(frame: self.view.bounds)
    background.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    background.image = UIImage(named: "background")
    self.view.insertSubview(background, atIndex: 0)
  }
  
}
