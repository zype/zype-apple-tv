//
//  SearchVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/14/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class SearchController: UISearchController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let effectView = self.view.superview?.subviews.first!, effectView.isKind(of: UIVisualEffectView.self) {
      effectView.isHidden = true
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
        self.collectionVC = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
        self.collectionVC.configWithSections([CollectionSection()])
        self.collectionVC.itemSelectedCallback = {(item: CollectionLabeledItem, section: CollectionSection) in
          self.playVideo(item.object as! VideoModel)
        }
        self.cachedVC = SearchController(searchResultsController: self.collectionVC)
        self.cachedVC.delegate = self
        self.cachedVC.searchResultsUpdater = self
        self.cachedVC.hidesNavigationBarDuringPresentation = false
        self.cachedVC.searchBar.placeholder = localized("Search.Placeholder")
      }
      return self.cachedVC
    }
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    let searchString = searchController.searchBar.text ?? ""
    if(self.lastSearchString != searchString) {
      self.lastSearchString = searchString
      if(searchString.isEmpty){
        self.collectionVC.configWithSections([CollectionSection()])
        return
      }
      ZypeAppleTVBase.sharedInstance.getVideos(QueryVideosModel(searchString: searchController.searchBar.text!, perPage: 100), completion: { (videos, error) -> Void in
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
