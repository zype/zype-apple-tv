//
//  FavoritesVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/15/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class FavoritesVC: CollectionContainerVC {
  
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var dataView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBarItem.title = localized("Favorites.TabTitle")
    self.collectionVC.collectionView?.contentInset.top = Const.kBaseSectionInsets.top
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.hideInfo()
    self.getFavorites()
  }
  
  func displayInfo(_ info: String) {
    self.infoLabel.text = info
    self.infoLabel.isHidden = false
    self.dataView.isHidden = true
  }
  
  func hideInfo() {
    self.infoLabel.isHidden = true
    self.dataView.isHidden = false
  }
  
  func cachedFavoriteByVideoID(_ ID: String) -> FavoriteCollectionItem? {
    if(self.collectionVC.sections.count > 0){
      for item in self.collectionVC.sections.first!.items as! Array<FavoriteCollectionItem> {
        if(item.videoID == ID) {
          return item
        }
      }
    }
    return nil
  }
  
  func getFavorites(){
    let defaults = UserDefaults.standard
    let favorites = defaults.array(forKey: Const.kFavoritesKey) as? Array<String> ?? [String]()
    let section = CollectionSection()
    section.headerStyle = .centered
    section.title = localized("Favorites.Title")
    for videoID in favorites {
      let item = self.cachedFavoriteByVideoID(videoID) ?? FavoriteCollectionItem(videoID: videoID)
      item.loadResources()
      section.items.append(item)
    }
    if(!self.collectionVC.isConfigurated) {
      self.collectionVC.configWithSections([section])
    } else {
      self.collectionVC.update([section])
    }
    
    if(section.items.count == 0) {
      self.displayInfo(localized("Favorites.NoFavorites"))
    }
    
//    ZypeAppleTVBase.sharedInstance.getFavorites({ (videos, error) -> Void in
//      let section = CollectionSection()
//      section.headerStyle = .Centered
//      section.title = localized("Favorites.Title")
//      if(videos != nil) {
//        for model in videos! {
//          section.items.append(FavoriteCollectionItem(favorite: model))
//        }
//      }
//      if(!self.collectionVC.isConfigurated) {
//        self.collectionVC.configWithSections([section])
//      } else {
//        self.collectionVC.update([section])
//      }
//      
//      if(error != nil) {
//        displayError(error)
//      }
//    })
  }
  
  override func onItemSelected(_ item: CollectionLabeledItem, section: CollectionSection?) {
    let favorite = item as! FavoriteCollectionItem
    if let _ = favorite.object {
      self.playVideo(favorite.object as! VideoModel)
    }
  }
  
}
