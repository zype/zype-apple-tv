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
import ZypeAppleTVBase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class PlayerVC: UIViewController, DVIABPlayerDelegate {
    
    // MARK: - Properties
    var adPlayer: DVIABPlayer?
    var playerLayer = AVPlayerLayer()
    var playerItem: AVPlayerItem!
    var playerController = AVPlayerViewController()
    var playerURL : URL!
    var playerView: DVPlayerView?
    var isSkippable = false
    var isResuming = true
    
    var beacon = ""
    var customDimensions = [String: String]()

    var playlist: Array<VideoModel>? = nil
    var currentVideo: VideoModel!
    var adsData: [adObject] = [adObject]()
    var adTimer: Timer!
    var currentTime: CMTime!
    
    var userDefaults = UserDefaults.standard
    var timeObserverToken: Any?
    var adsArray: NSMutableArray?
    var url: NSURL?
    
    // added for past programs
    var startTime: String? = nil
    var endTime: String? = nil
    
    var completionDelegate: ChangeVideoDelegate? = nil
    
    // MARK: - View Lifecycle
    deinit {
        print("Destroying")
        
        NotificationCenter.default.removeObserver(self)
        if self.adPlayer != nil {
            self.removeAdPlayer()
            self.adPlayer = nil
        }
        if self.playerController.player != nil {
            self.playerController.player?.pause()
        }
        
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime = CMTimeMake(250, 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.play(self.currentVideo)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsManager.sharedInstance.reset()
        
        if self.completionDelegate != nil && self.currentVideo != nil {
            self.completionDelegate?.changeFocusVideo(self.currentVideo)
        }
    }

    // MARK: - User Interaction
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        //type == .Select
        if let type = presses.first?.type, type == .playPause {
            if self.adPlayer != nil {
                
            }
        }
            
        else if let type = presses.first?.type, type == .select {
            if self.adPlayer != nil {
                if self.isSkippable == true {
                    if let viewWithTag = self.view.viewWithTag(1001) {
                        viewWithTag.removeFromSuperview()
                    }
                    self.nextAdPlayer()
                }
            }
        }
            
        else if let type = presses.first?.type, type == .menu {
            if !currentVideo.onAir {
                let timeStamp = self.playerController.player?.currentTime().seconds
                if timeStamp > 30.0 {
                    userDefaults.setValue(timeStamp, forKey: "\(currentVideo.getId())")
                }
            }
            
            NotificationCenter.default.removeObserver(self)
            if self.adPlayer != nil {
                self.adPlayer?.pause()
            }
            if self.playerController.player != nil {
                self.playerController.player?.pause()
                AnalyticsManager.sharedInstance.trackStop()
            }
            self.removePeriodicTimeObserver()
        }
    }
    
    // MARK: - Video Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.adPlayer!.status == .readyToPlay {
            if self.adPlayer?.contentPlayerItem.currentTime().seconds < 0.5 && self.adPlayer?.contentPlayerItem.currentTime().seconds > 0.0 {
                self.removeAdPlayer()
                self.setupVideoPlayer()
            }
            else {
                DispatchQueue.main.async(execute: {
                    self.adPlayer!.play()
                })
            }
        }
        else if self.adPlayer!.status == .failed {
            self.removeAdPlayer()
            self.setupVideoPlayer()
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func play(_ model: VideoModel) {
        model.getVideoObject(.kVimeoHls, completion: {[unowned self] (playerObject: VideoObjectModel?, error: NSError?) in
            if let _ = playerObject, let videoURL = playerObject?.videoURL, var url = NSURL(string: videoURL), error == nil {
                
                if let startTime = self.startTime, let endTime = self.endTime {
                    guard let newUrl = NSURL(string: "\(videoURL)&start=\(startTime)&end=\(endTime)") else {
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    url = newUrl
                }
                
                self.currentVideo = model
                if self.validateEntitlement(for: playerObject) {
                    let adsArray = self.getAdsFromResponse(playerObject)
                    self.playerURL = url as URL
                    self.adsArray = adsArray
                    self.url = url

                    let analyticsInfo = self.getAnalyticsFromResponse(playerObject)
                    self.beacon = analyticsInfo.beacon
                    self.customDimensions = analyticsInfo.customDimensions

                    if adsArray.count > 0 && self.adsData.last?.offset == 0 { // check for preroll
                        self.playAds(adsArray: adsArray, url: url)
                        _ = self.adsData.popLast()
                    }
                    else {
                        self.setupVideoPlayer()
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                self.navigationController?.popViewController(animated: true)
                displayError(error)
            }
        })
    }
    
    fileprivate func validateEntitlement(for playerObject: VideoObjectModel?) -> Bool {
        if (playerObject?.json?["message"]) != nil {
//            let alert = UIAlertController(title: "Error", message: responseMessage as? String, preferredStyle: .alert)
//            let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in
//                self.dismiss(animated: true, completion: nil)
//            })
//            alert.addAction(confirmAction)
//            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func setupVideoPlayer() {
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        let player = AVPlayer(url: self.playerURL)
        self.playerController.player = player
        self.addChildViewController(self.playerController)
        self.view.addSubview(self.playerController.view)
        self.playerController.view.frame = self.view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        if self.adsData.count > 0 {
            self.observeTimerForMidrollAds()
        }
        
        if isResuming {
            if !currentVideo.onAir {
                if let timeStamp = userDefaults.object(forKey: "\(currentVideo.getId())") {
                    let time = CMTimeMakeWithSeconds(timeStamp as! Float64, 1)
                    player.seek(to: time)
                }
            }
        }

        if !self.beacon.isEmpty && !self.customDimensions.isEmpty {
            if let url = URL(string: self.beacon) {
                AnalyticsManager.sharedInstance.trackPlayer(withConfigUrl: url, withPlayer: player, withCustomData: self.customDimensions)
            }
        }

        player.play()
    }
    
    func resumePlayingFromAds() {
        self.removeAdPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController.player?.currentItem)
        
        if let player = self.playerController.player {
            player.play()
        }
        else {
            setupVideoPlayer()
        }
    }
    
    func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (self.playerController.player?.currentItem != nil) && ((notification.object as! AVPlayerItem) == self.playerController.player!.currentItem) {
            userDefaults.removeObject(forKey: self.currentVideo.getId())
            
            self.playerController.removeFromParentViewController()
            self.playerController.view.removeFromSuperview()
            self.playerController.player?.replaceCurrentItem(with: nil)
            self.playerController = AVPlayerViewController()

            AnalyticsManager.sharedInstance.trackStop()

            if let _ = self.playlist,
                let currentVideoIndex = self.playlist?.index(of: self.currentVideo), self.playlist?.count > 0 {
                
                if currentVideoIndex + 1 < self.playlist!.count {
                    let nextVideo = self.playlist![currentVideoIndex + 1]
                    self.play(nextVideo)
                }
                else {
                    self.play(self.playlist!.first!)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - DVIABPlayerDelegate
    func player(_ player: DVIABPlayer!, shouldPauseForAdBreak playBreak: DVVideoPlayBreak!) -> Bool {
        return true
    }
    
    func player(_ player: DVIABPlayer!, didFail playBreak:DVVideoPlayBreak!, withError:Error ) {
        print("did fail playback")
    }

}
