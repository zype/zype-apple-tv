//
//  Const.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//
// GIT DESCRIPTION: <GIT_DESCRIPTION>

import UIKit
import ZypeAppleTVBase

class Const: NSObject {

  static let sdkSettings = SettingsModel(clientID: "<CLIENT_ID>",
    secret: "<CLIENT_SECRET>",
    appKey: "<APP_KEY>",
    apiDomain:"https://api.zype.com",
    tokenDomain: "https://login.zype.com",
    userAgent: "zype tvos")


  static let kBaseSectionInsets: UIEdgeInsets = UIEdgeInsets(top: 50, left: 90, bottom: 50, right: 90)
  static let kCollectionCellSize: CGSize = CGSize(width: 308, height: 220)
  static let kShowCellHeight: CGFloat = 310
  static let kCollectionHorizontalSpacing: CGFloat = 50.0
  static let kCollectionVerticalSpacing: CGFloat = 50.0
  static let kCollectionSectionHeaderHeight: CGFloat = 45.0
  static let kCollectionPagerCellSize: CGSize = CGSize(width: 1740, height: 490)
  static let kCollectionPagerVCBottomMargin: CGFloat = 70.0
  static let kCollectionSectionHeaderBottomMargin: CGFloat = 25.0
  static let kCollectionPagerHorizontalSpacing: CGFloat = 20.0
  static let kScrollableTextVCMaskInsets: UIEdgeInsets = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
  static let kFavoritesKey = "Favorites"
}
