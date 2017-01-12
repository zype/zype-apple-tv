//
//  ViewController.swift
//  UITest
//
//  Created by Eugene Lizhnyk on 10/8/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class HomeVC: CollectionContainerVC, UINavigationControllerDelegate {
  
  static let kShowDetailsSegueID = "ShowDetails"
  
  @IBOutlet weak var collectionWrapperView: UIView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var infoLabel: StyledLabel!
  @IBOutlet weak var reloadButton: UIButton!
  
  static let kMaxVideosInSection = 20
  
  var pagerVC: BaseCollectionVC!
  var selectedVideo: VideoModel!
  var selectedShow: PlaylistModel!
  var playlists = [PlaylistModel]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.delegate = self
    self.reloadButton.setTitle(localized("Home.ReloadButton"), for: UIControlState())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.reloadData()
  }
  
  func playlistByID(_ ID: String) -> PlaylistModel? {
    for playlist in self.playlists {
      if(playlist.ID == ID) {
        return playlist
      }
    }
    return nil
  }
  
  func reloadData() {
    self.hideErrorInfo()
    ZypeAppleTVBase.sharedInstance.getPlaylists(completion: {[unowned self] (playlists: Array<PlaylistModel>?, error: NSError?) in
      if(error == nil && playlists != nil) {
        self.playlists = playlists!
        self.getLivestreamItem({(result: CollectionLabeledItem?) in
          self.getFeaturedVideos(result, callback: {[unowned self] in
            self.fillSections()
          })
        })
      } else {
        self.fillSections()
        self.showErrorInfo(error?.localizedDescription)
      }
    })
  }
  
  func getLivestreamItem(_ callback: @escaping (_ result: CollectionLabeledItem?)->()) {
    let queryModel = QueryVideosModel()
    queryModel.onAir = true
    queryModel.sort = "published_at"
    queryModel.ascending = false
    ZypeAppleTVBase.sharedInstance.getVideos(queryModel, completion: {(videos: Array<VideoModel>?, error: NSError?) in
      if let _ = videos, videos!.count > 0 {
        let video = videos!.first!
        let item = CollectionLabeledItem()
        item.object = video
        item.imageName = "on_air"
        callback(item)
      } else {
        callback(nil)
      }
    })
  }
  
  func playlistForZObject(_ object: ZobjectModel) -> PlaylistModel? {
    let playlistID = object.getStringValue("playlistid")
    if let show = self.playlistByID(playlistID) {
      return show
    }
    return nil
  }
  
  func getFeaturedVideos(_ livestreamItem: CollectionLabeledItem?, callback: @escaping () -> Void) {
    let type = QueryZobjectsModel()
    type.zobjectType = "top_playlists"
    ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
      if let _ = objects, objects!.count > 0 {
        var items = CollectionContainerVC.featuresToCollectionItems(objects)
        if let _ = livestreamItem {
          items.insert(livestreamItem!, at: items.count / 2)
        }
        let section = CollectionSection()
        section.isPager = true
        section.items = items
        section.insets.top = 0
        section.insets.bottom = 0
        section.horizontalSpacing = Const.kCollectionPagerHorizontalSpacing
        section.cellSize = Const.kCollectionPagerCellSize
        
        if(self.pagerVC == nil) {
          self.pagerVC = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
          self.pagerVC.view.height = Const.kCollectionPagerCellSize.height
          self.pagerVC.isInfinityScrolling = true
          self.collectionVC.addChildViewController(self.pagerVC)
          self.pagerVC.didMove(toParentViewController: self.collectionVC)
          self.pagerVC.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
            if(item.object is VideoModel) {
              self.playVideo(item.object as! VideoModel)
              return
            }
            let zObject = (item as! PagerCollectionItem).object as! ZobjectModel
            if let playlist = self.playlistForZObject(zObject) {
              playlist.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                if((videos?.count)! > 0) {
                  self.selectedVideo = videos!.first!
                  self.selectedShow = playlist
                  self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: section)
                }
              })
            }
          }
          self.pagerVC.configWithSection(section)
        } else {
          self.pagerVC.update([section])
        }
      }
      
      callback()
    })
  }
  
  func fillSections(){
    var sections = [] as Array<CollectionSection>
    if(self.pagerVC != nil) {
      let headerSection = CollectionSection()
      headerSection.controller = self.pagerVC
      headerSection.insets = UIEdgeInsetsMake(0, 0, Const.kCollectionPagerVCBottomMargin, 0)
      sections.append(headerSection)
    }
    sections.append(contentsOf: self.getSectionsForShows())
    self.collectionVC.configWithSections(sections)
    if(sections.count == 0 && self.pagerVC == nil) {
      self.showErrorInfo()
    }
  }
  
  func getSectionsForShows() -> Array<CollectionSection> {
    var result = [CollectionSection]()
    for value in self.playlists {
      result.append(self.sectionForValue(value))
    }
    return result
  }
  
  func sectionForValue(_ value: PlaylistModel) -> CollectionSection {
    var controllerSection: CollectionSection
    var controller: BaseCollectionVC
    
    if let existedSection = self.collectionVC.sectionForObject(value), existedSection.controller != nil {
      controllerSection = existedSection
      controller = existedSection.controller as! BaseCollectionVC
    } else {
      controllerSection = CollectionSection()
      controller = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
    }

    value.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
      var videoItems = CollectionContainerVC.videosToCollectionItems(videos)
      if(videoItems.count > HomeVC.kMaxVideosInSection) {
        let lastVideo = videoItems[HomeVC.kMaxVideosInSection] as! VideoCollectionItem
        videoItems = Array(videoItems[0..<HomeVC.kMaxVideosInSection])
        videoItems.append(lastVideo.convertToMore())
      }
      let videosSection = CollectionSection()
      videosSection.items = videoItems
      videosSection.object = value
      videosSection.insets.top = 0
      videosSection.insets.bottom = 0
      if(!controller.isConfigurated) {
        controller.configWithSection(videosSection)
      } else {
        controller.update([videosSection])
      }
    })
    
    controller.view.height = Const.kCollectionCellSize.height
    controller.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
      self.selectedVideo = item.object as! VideoModel
      self.selectedShow = section.object as! PlaylistModel
      self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: section)
    }
  
    controllerSection.controller = controller
    controllerSection.title = value.titleString
    controllerSection.object = value
    controllerSection.insets.top = Const.kCollectionSectionHeaderBottomMargin
    controllerSection.insets.bottom = Const.kBaseSectionInsets.bottom
    return controllerSection
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == HomeVC.kShowDetailsSegueID) {
      let detailsVC = segue.destination as! ShowDetailsVC
      detailsVC.selectedShow = self.selectedShow
      detailsVC.selectedVideo = self.selectedVideo
    }
    super.prepare(for: segue, sender: sender)
  }
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = FadeNavigationAnimationController()
    animationController.reverse = operation == .pop
    return animationController
  }
  
  func showErrorInfo(_ description: String? = nil) {
    self.infoView.isHidden = false
    self.collectionWrapperView.isHidden = true
    self.infoLabel.text = description ?? localized("Home.DefaultErrorMessage")
  }
  
  func hideErrorInfo() {
    self.infoView.isHidden = true
    self.collectionWrapperView.isHidden = false
  }
  
  @IBAction func onReload(_ sender: AnyObject) {
    ZypeAppleTVBase.sharedInstance.reset()
    ZypeAppleTVBase.sharedInstance.initialize(Const.sdkSettings, loadCategories: false, loadPlaylists: false, completion: {_ in})
    self.hideErrorInfo()
    self.reloadData()
  }
  
}

