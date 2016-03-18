//
//  SearchVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/14/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeSDK

class SearchController: UISearchController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let effectView = self.view.superview?.subviews.first! where effectView.isKindOfClass(UIVisualEffectView) {
      effectView.hidden = true
    }
  }
}

class SearchVC: UISearchContainerViewController, UISearchControllerDelegate, UISearchResultsUpdating {

  var lastSearchString: String!
  var isFirstSearch: Bool = true
  var collectionVC: BaseCollectionVC!
  var cachedVC: UISearchController!
  
  override internal var searchController: UISearchController {
    get {
      if(self.cachedVC == nil){
        self.collectionVC = self.storyboard?.instantiateViewControllerWithIdentifier("BaseCollectionVC") as! BaseCollectionVC
        self.collectionVC.configWithSections([CollectionSection()])
        self.collectionVC.itemSelectedCallback = {(item: CollectionLabeledItem, section: CollectionSection) in
          self.playVideo(item.object as! VideoModel)
        }
        self.cachedVC = SearchController(searchResultsController: self.collectionVC)
        self.cachedVC.delegate = self
        self.cachedVC.searchResultsUpdater = self
        self.cachedVC.hidesNavigationBarDuringPresentation = false
        
        // search bar and keyboard styles
        self.cachedVC.searchBar.placeholder = localized("Search.Placeholder")
        self.cachedVC.searchBar.tintColor = UIColor.blackColor()
        self.cachedVC.searchBar.barTintColor = UIColor.blackColor()
        self.cachedVC.searchBar.searchBarStyle = .Minimal
        self.cachedVC.searchBar.keyboardAppearance = UIKeyboardAppearance.Light
      }
      return self.cachedVC
    }
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let searchString = searchController.searchBar.text ?? ""
    if(self.lastSearchString != searchString) {
      self.lastSearchString = searchString
      if(searchString.isEmpty){
        self.collectionVC.configWithSections([CollectionSection()])
        return
      }
      ZypeSDK.sharedInstance.getVideos(QueryVideosModel(searchString: searchController.searchBar.text!, perPage: 100), completion: { (videos, error) -> Void in
          if(searchString == searchController.searchBar.text) {
              let section = CollectionSection()
              section.title = String(format: localized("Search.Results"), arguments: [videos == nil ? 0 : videos!.count])
              section.items = CollectionContainerVC.videosToCollectionItems(videos)
              if(self.isFirstSearch){
                  self.isFirstSearch = false
                  self.collectionVC.configWithSections([section])
              } else {
                  self.collectionVC.update([section])
              }
          }
      })
    }
  }
  
}
