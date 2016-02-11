//
//  CollectionContainerVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/15/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeSDK
import AVKit
import AVFoundation


class FavoriteCollectionItem: CollectionLabeledItem {
  var videoID: String!
  
  init(videoID: String) {
    super.init()
    self.title = ""
    self.videoID = videoID
  }
  
  override func loadResources(){
    let queryModel = QueryVideosModel()
    queryModel.videoID = self.videoID
    ZypeSDK.sharedInstance.getVideos(queryModel, completion: {(videos: Array<VideoModel>?, error: NSError?) in
      if let _ = videos where videos!.count > 0 {
        let video = videos!.first! as VideoModel
        self.object = video
        self.imageURL = video.thumbnailURL()
        self.title = video.titleString
      }
    })
  }
}


class VideoCollectionItem: CollectionLabeledItem {
  init(video: VideoModel) {
    super.init()
    self.title = video.titleString
    self.imageURL = video.thumbnailURL()
    self.object = video
  }
  
  func convertToMore() -> MoreVideoCollectionItem {
    return MoreVideoCollectionItem(video: self.object as! VideoModel)
  }
}


class MoreVideoCollectionItem: VideoCollectionItem {
  override init(video: VideoModel) {
    super.init(video: video)
    self.title = ""
    self.imageName = "ViewMore"
    self.imageURL = nil
    self.object = video
  }
}


class PagerCollectionItem: CollectionLabeledItem {
  init(object: ZobjectModel) {
    super.init()
    if(object.pictures.count > 0) {
      self.imageURL = NSURL(string: object.pictures.first!.url)
    }
    self.object = object
  }
}


class ShowCollectionItem: CollectionLabeledItem {
  init(value: PlaylistModel) {
    super.init()
    self.title = value.titleString
    self.object = value
  }
}

extension UIViewController {
  
  func playVideo(model: VideoModel, playlist: Array<VideoModel>? = nil) {
      let playerVC = self.storyboard?.instantiateViewControllerWithIdentifier("PlayerVC") as! PlayerVC
      playerVC.currentVideo = model
      playerVC.playlist = playlist
      self.presentViewController(playerVC, animated: true, completion: nil)
  }
  
}

class CollectionContainerVC: UIViewController {

  var collectionVC: BaseCollectionVC! {
    didSet {
      self.collectionVC.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
        self.onItemSelected(item, section: section)
      }
      self.collectionVC.itemFocusedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
        self.onItemFocused(item, section: section)
      }
    }
  }
  
  override weak var preferredFocusedView: UIView? {
    get {
      return self.collectionVC.focusedCell() ?? super.preferredFocusedView
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    for vc in self.childViewControllers {
      if(vc.isKindOfClass(BaseCollectionVC)) {
        self.collectionVC = vc as! BaseCollectionVC
        break
      }
    }
  }
  
  static func videosToCollectionItems(videos: Array<VideoModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(videos)
  }
  
  static func featuresToCollectionItems(features: Array<ZobjectModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(features)
  }
  
  static func categoryValuesToCollectionItems(values: Array<PlaylistModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(values)
  }
  
  static private func modelsToCollectionItems(models: Array<BaseModel>?) -> Array<CollectionLabeledItem> {
    var result = [CollectionLabeledItem]()
    if(models == nil) {
      return result
    }
    for model in models! {
      var mapped: CollectionLabeledItem!
      if(model.isKindOfClass(VideoModel)) {
        mapped = VideoCollectionItem(video: model as! VideoModel)
      } else if(model.isKindOfClass(PlaylistModel)) {
        mapped = ShowCollectionItem(value: model as! PlaylistModel)
      } else if(model.isKindOfClass(ZobjectModel)) {
        mapped = PagerCollectionItem(object: model as! ZobjectModel)
      }
      if(mapped != nil) {
        result.append(mapped)
      }
    }
    return result
  }
  
  func onItemFocused(item: CollectionLabeledItem, section: CollectionSection?){}
  func onItemSelected(item: CollectionLabeledItem, section: CollectionSection?){}
  
}
