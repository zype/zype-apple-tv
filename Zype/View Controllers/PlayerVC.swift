//
//  PlayerVC.swift
//  UITest
//
//  Created by Eugene Lizhnyk on 10/8/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ZypeSDK

class PlayerVC: AVPlayerViewController {
  
  var playlist: Array<VideoModel>? = nil
  var currentVideo: VideoModel!

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.play(self.currentVideo)
  }
  
  func videoReachedEnd(notification: NSNotification) {
    if let _ = self.playlist,
      let currentVideoIndex = self.playlist?.indexOf(self.currentVideo)
      where self.playlist?.count > 0 {
      if(currentVideoIndex + 1 < self.playlist!.count) {
        let nextVideo = self.playlist![currentVideoIndex + 1]
        self.play(nextVideo)
      } else {
        self.play(self.playlist!.first!)
      }
    }
  }
  
  func play(model: VideoModel) {
    model.getVideoObject(.kVimeoHls, completion: {[unowned self] (playerObject: VideoObjectModel?, error: NSError?) in
      if let _ = playerObject,
        let videoURL = playerObject?.videoURL,
        let url = NSURL(string: videoURL)
        where error == nil {
          self.player = AVPlayer(playerItem: AVPlayerItem(URL: url))
          self.player?.play()
          self.currentVideo = model
      } else {
        self.navigationController?.popViewControllerAnimated(true)
        displayError(error)
      }
    })
  }
  
}
