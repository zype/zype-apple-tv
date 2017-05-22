//
//  CollectionContainerVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/15/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase
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
    ZypeAppleTVBase.sharedInstance.getVideos(queryModel, completion: {(videos: Array<VideoModel>?, error: NSError?) in
      if let _ = videos, videos!.count > 0 {
        let video = videos!.first! as VideoModel
        self.object = video
        self.imageURL = video.thumbnailURL() as URL!
        self.title = video.titleString
      }
    })
  }
}


class VideoCollectionItem: CollectionLabeledItem {
  init(video: VideoModel) {
    super.init()
    self.title = video.titleString
    self.imageURL = video.thumbnailURL() as URL!
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
      self.imageURL = NSURL(string: object.pictures.first!.url) as URL!
    }
    self.object = object
  }
}


class ShowCollectionItem: CollectionLabeledItem {
    init(value: PlaylistModel) {
        super.init()
        self.title = value.titleString
        if(value.images.count > 0) {
            self.imageURL = NSURL(string: value.images.first!.imageURL) as URL!
        } else if (value.thumbnails.count > 0) {
            self.imageURL = NSURL(string: value.thumbnails.first!.imageURL) as URL!
        } else {
            self.imageURL = NSURL(string: "http://placehold.it/320x180") as URL!
        }
        self.object = value
    }
}

extension UIViewController {
  
    func playVideo(_ model: VideoModel, playlist: Array<VideoModel>? = nil, isResuming: Bool = true) {
        if (model.onAir) {
            
        } else {
            //check for video with subscription
            if (model.subscriptionRequired && !ZypeUtilities.isDeviceLinked()) {
                ZypeUtilities.presentLoginVC(self)
                return
            }
        }
        
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
        playerVC.currentVideo = model
        playerVC.playlist = playlist
        playerVC.isResuming = isResuming
        self.present(playerVC, animated: true, completion: nil)
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
      if(vc.isKind(of: BaseCollectionVC.self)) {
        self.collectionVC = vc as! BaseCollectionVC
        break
      }
    }
  }
  
  static func videosToCollectionItems(_ videos: Array<VideoModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(videos)
  }
  
  static func featuresToCollectionItems(_ features: Array<ZobjectModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(features)
  }
  
  static func categoryValuesToCollectionItems(_ values: Array<PlaylistModel>?) -> Array<CollectionLabeledItem> {
    return self.modelsToCollectionItems(values)
  }
  
  static fileprivate func modelsToCollectionItems(_ models: Array<BaseModel>?) -> Array<CollectionLabeledItem> {
    var result = [CollectionLabeledItem]()
    if(models == nil) {
      return result
    }
    for model in models! {
      var mapped: CollectionLabeledItem!
        
      if(model is VideoModel) {
        mapped = VideoCollectionItem(video: model as! VideoModel)
      } else if(model is PlaylistModel) {
        mapped = ShowCollectionItem(value: model as! PlaylistModel)
      } else if(model is ZobjectModel) {
        mapped = PagerCollectionItem(object: model as! ZobjectModel)
      }
      if(mapped != nil) {
        result.append(mapped)
      }
    }
    return result
  }
  
  func onItemFocused(_ item: CollectionLabeledItem, section: CollectionSection?){}
  func onItemSelected(_ item: CollectionLabeledItem, section: CollectionSection?){}
  
}
