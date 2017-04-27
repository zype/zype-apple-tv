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


class PlayerVC: UIViewController, DVIABPlayerDelegate
{
    var adPlayer: DVIABPlayer?
    var playerLayer = AVPlayerLayer()
    var playerItem: AVPlayerItem!
    var playerController = AVPlayerViewController()
    var playerURL : URL!
    var playerView: DVPlayerView?
    var isSkippable = false
    var isResuming = true
    
    var playlist: Array<VideoModel>? = nil
    var currentVideo: VideoModel!
    var adTimer: Timer!
    
    var adsData: [adObject] = [adObject]()
    
    var currentTime : CMTime!
    var userDefaults = UserDefaults.standard
    
    deinit {
        print("Destroying")
        
        NotificationCenter.default.removeObserver(self)
        if self.adPlayer != nil
        {
            print("ad Player")
            self.removeAdPlayer()
            print("ad Player removed")
            self.adPlayer = nil
        }
        if self.playerController.player != nil
        {
            print("playerController")
            self.playerController.player?.pause()
            print("playerController paused")
        }
        //    self.adsManager?.destroy()
        
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            print("view 1001 removing")
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002)
        {
            print("view 1002 removing")
            viewWithTag.removeFromSuperview()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime = CMTimeMake(250, 1)
        
        //    NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.play(self.currentVideo)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        print("presses began \(String(describing: presses.first?.type))")
        //type == .Select
        if let type = presses.first?.type, type == .playPause
        {
            if self.adPlayer != nil
            {
                /*              if self.adPlayer?.rate == 1.0
                 {
                 self.adPlayer?.play()
                 }
                 else
                 {
                 self.adPlayer?.pause()
                 }*/
            }
        }
        else if let type = presses.first?.type, type == .select
        {
            if self.adPlayer != nil
            {
                if self.isSkippable == true
                {
                    if let viewWithTag = self.view.viewWithTag(1001)
                    {
                        viewWithTag.removeFromSuperview()
                    }
                    self.nextAdPlayer()
                    //                    self.setupAVPlayer()
                }
            }
        } else if let type = presses.first?.type, type == .menu
        {
            print("menu clicked")
            if !currentVideo.onAir
            {
                let timeStamp = self.playerController.player?.currentTime().seconds
                if timeStamp > 30.0 {
                    userDefaults.setValue(timeStamp, forKey: "\(currentVideo.getId())")
                }
            }
            
            NotificationCenter.default.removeObserver(self)
            if self.adPlayer != nil
            {
                self.adPlayer?.pause()
            }
            if self.playerController.player != nil
            {
                self.playerController.player?.pause()
            }
            
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?)
    {
        super.pressesEnded(presses, with: event)
    }
    
    func videoReachedEnd(_ notification: Notification) {
        if let _ = self.playlist,
            let currentVideoIndex = self.playlist?.index(of: self.currentVideo), self.playlist?.count > 0 {
            if(currentVideoIndex + 1 < self.playlist!.count) {
                let nextVideo = self.playlist![currentVideoIndex + 1]
                self.play(nextVideo)
            } else {
                self.play(self.playlist!.first!)
            }
        }
    }
    
    func play(_ model: VideoModel)
    {
        model.getVideoObject(.kVimeoHls, completion: {[unowned self] (playerObject: VideoObjectModel?, error: NSError?) in
            if let _ = playerObject, let videoURL = playerObject?.videoURL, let url = NSURL(string: videoURL), error == nil
            {
                let adsArray = self.getAdsFromResponse(playerObject)
                
                self.playerURL = url as URL!

                if adsArray.count == 0
                {
                    self.setupVideoPlayer()
                }
                else
                {
                    self.adPlayer = DVIABPlayer()
                    
                    let screenSize = UIScreen.main.bounds
                    self.playerView = DVPlayerView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height))
                    
                    self.adPlayer!.playerLayer = self.playerView?.layer as! AVPlayerLayer
                    (self.playerView?.layer as! AVPlayerLayer).player = self.adPlayer
                    self.view.addSubview(self.playerView!)
                    
                    let adPlaylist = DVVideoMultipleAdPlaylist()
                    
                    print(adsArray)
                    
                    adPlaylist.playBreaks = NSArray(array: adsArray.copy() as! [AnyObject]) as [AnyObject]
                    self.adPlayer!.adPlaylist = adPlaylist
                    self.adPlayer!.delegate = self
                    
                    self.playerItem = AVPlayerItem(url: url as URL)
                    self.playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
                    self.adPlayer!.contentPlayerItem = self.playerItem
                    self.adPlayer!.replaceCurrentItem(with: self.playerItem)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.setupAdTimer), name: NSNotification.Name(rawValue: "setupAdTimer"), object: nil)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.removeAdTimer), name: NSNotification.Name(rawValue: "removeAdTimer"), object: nil)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.addAdLabel), name: NSNotification.Name(rawValue: "adPlaying"), object: nil)
                    
                    //this is called when there are ad tags, but they don't return any ads
                    NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.removeAdsAndPlayVideo), name: NSNotification.Name(rawValue: "noAdsToPlay"), object: nil)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.adPlayer!.contentPlayerItem)
                }
                
                self.currentVideo = model
                
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
                displayError(error)
            }
        })
    }
    
    func contentDidFinishPlaying(_ notification: Notification)
    {
        userDefaults.removeObject(forKey: self.currentVideo.getId())
        print("\n\n---content did finish playing---\n\n")
        // Make sure we don't call contentComplete as a result of an ad completing.
        if ((notification.object as! AVPlayerItem) == self.playerController.player!.currentItem)
        {
            self.playerController.removeFromParentViewController()
            self.playerController.view.removeFromSuperview()
            self.playerController.player?.replaceCurrentItem(with: nil)
            self.playerController = AVPlayerViewController()
            
            if let _ = self.playlist,
                let currentVideoIndex = self.playlist?.index(of: self.currentVideo), self.playlist?.count > 0 {
                if(currentVideoIndex + 1 < self.playlist!.count) {
                    let nextVideo = self.playlist![currentVideoIndex + 1]
                    self.play(nextVideo)
                } else {
                    self.play(self.playlist!.first!)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if self.adPlayer!.status == .readyToPlay
        {
            print("ready to play: \(self.adPlayer!.contentPlayerItem.currentTime().seconds)")
            if self.adPlayer?.contentPlayerItem.currentTime().seconds < 0.5 && self.adPlayer?.contentPlayerItem.currentTime().seconds > 0.0 //|| self.adPlayer?.currentInlineAd == nil
            {
                print("remove ad player and setup video player")
                self.removeAdPlayer()
                
                self.setupVideoPlayer()
            }
            else
            {
                print("play ads")
                DispatchQueue.main.async(execute: {
                    self.adPlayer!.play()
                })
                
            }
        }
        else if self.adPlayer!.status == .failed
        {
            print("ad player failed")
            
            self.removeAdPlayer()
            
            self.setupVideoPlayer()
        }
        else
        {
            print("some other status")
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func removeAdPlayer()
    {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002)
        {
            viewWithTag.removeFromSuperview()
        }
        
        self.playerItem.removeObserver(self, forKeyPath: "status", context: nil)
        self.adPlayer!.pause()
        self.playerLayer.removeFromSuperlayer()
        self.adPlayer!.adPlaylist = DVVideoMultipleAdPlaylist()
        self.adPlayer!.contentPlayerItem = nil
        self.adPlayer?.replaceCurrentItem(with: nil)
        self.adPlayer = nil
        self.playerItem = nil
        self.playerView!.removeFromSuperview()
        self.playerView = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func removeAdTimer()
    {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002)
        {
            viewWithTag.removeFromSuperview()
        }
        
        if self.adTimer != nil
        {
            self.adTimer.invalidate()
        }
    }
    
    func setupAdTimer()
    {
        self.adTimer = Timer.scheduledTimer(timeInterval: self.adPlayer!.currentInlineAd.skippableDuration, target: self, selector: #selector(PlayerVC.adTimerDidFire), userInfo: nil, repeats: false)
    }
    
    func adTimerDidFire()
    {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        let screenSize = UIScreen.main.bounds
        let skipView = UIView(frame: CGRect(x: screenSize.width,y: screenSize.height - 300,width: 400,height: 200))
        skipView.tag = 1001
        skipView.backgroundColor = UIColor.black
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRect(x: skipView.bounds.size.width - 250,y: skipView.bounds.size.height - 200,width: 100,height: 100))
        skipLabel.text = "Skip"
        skipLabel.font = UIFont.systemFont(ofSize: 30)
        skipLabel.textColor = UIColor.white
        skipLabel.textAlignment = .center
        skipView.addSubview(skipLabel)
        self.view.addSubview(skipView)
        self.view.bringSubview(toFront: skipView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            
            skipView.frame = CGRect(x: screenSize.width - 400,y: screenSize.height - 300,width: 400,height: 100)
            
        }) { (done) in
            self.isSkippable = true
        }
    }
    
    func nextAdPlayer()
    {
        print("next add player")
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002)
        {
            viewWithTag.removeFromSuperview()
        }
        
        if self.adPlayer?.adsQueue.count > 0
        {
            self.adPlayer?.finishCurrentInlineAd(self.adPlayer?.currentInlineAdPlayerItem)
        }
        else
        {
            //self.adPlayer?.finishCurrentInlineAd(nil)
            self.removeAdPlayer()
            self.setupVideoPlayer()
        }
    }
    
    //MARK DVIABPlayerDelegate
    func player(_ player: DVIABPlayer!, shouldPauseForAdBreak playBreak: DVVideoPlayBreak!) -> Bool
    {
        print("should pause for ad break? Yes")
        return true
    }
    
    func player(_ player: DVIABPlayer!, didFail playBreak:DVVideoPlayBreak!, withError:Error ) {
        print("did fail playback")
    }
    
    
    func setupVideoPlayer()
    {
        print("setting up video player")
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002)
        {
            viewWithTag.removeFromSuperview()
        }
        let player = AVPlayer(url: self.playerURL)
        self.playerController.player = player
        self.addChildViewController(self.playerController)
        self.view.addSubview(self.playerController.view)
        self.playerController.view.frame = self.view.frame
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        // resume if possible
        if isResuming {
            if !currentVideo.onAir
            {
                if let timeStamp = userDefaults.object(forKey: "\(currentVideo.getId())")
                {
                    let time = CMTimeMakeWithSeconds(timeStamp as! Float64, 1)
                    player.seek(to: time)
                }
            }
        }
        player.play()
    }
    
    func addAdLabel() {
        print("adding ad label \(self.adsData)")
        
        let screenSize = UIScreen.main.bounds
        let skipView = UIView(frame: CGRect(x: screenSize.width-250,y: 30,width: 250,height: 40))
        skipView.tag = 1002
        skipView.backgroundColor = UIColor.black
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 100,height: 40))
        skipLabel.text = "Ad"
        skipLabel.font = UIFont.systemFont(ofSize: 30)
        skipLabel.textColor = UIColor.white
        skipLabel.textAlignment = .center
        skipView.addSubview(skipLabel)
        self.playerView?.addSubview(skipView)
        //self.view.bringSubviewToFront(skipView)
    }
    
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray {
        var adsArray = NSMutableArray()
        //print(playerObject?.json ?? <#default value#>)
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary
        {
            if let advertising = body["advertising"] as? NSDictionary{
                let schedule = advertising["schedule"] as? NSArray
                
                self.adsData = [adObject]()
                
                if (schedule != nil) {
                    for i in 0..<schedule!.count
                    {
                        let adDict = schedule![i] as! NSDictionary
                        let ad = adObject(offset: adDict["offset"] as? Double, tag:adDict["tag"] as? String)
                        self.adsData.append(ad)
                    }
                }
            }
        }
        
        if self.adsData.count > 0
        {
            
            /*let ad = adObject(offset: 0, tag:"https://s3.amazonaws.com/demo.jwplayer.com/advertising/assets/vast3_jw_ads.xml")
             self.adsData.removeAll()
             self.adsData.append(ad)*/
            
            for i in 0..<self.adsData.count
            {
                let ad = self.adsData[i]
                //preroll
                if ad.offset == 0
                {
                    print(ad.tag!)
                    adsArray.add(DVVideoPlayBreak.playBreakBeforeStart(withAdTemplateURL: URL(string: ad.tag!)!))
                    // adsArray.addObject(DVVideoPlayBreak.playBreakAtTimeFromStart(CMTimeMake(10,1), withAdTemplateURL: NSURL(string: ad.tag!)!))
                    //  adsArray.addObject(DVVideoPlayBreak.playBreakAtTimeFromStart(CMTimeMake(20,1), withAdTemplateURL: NSURL(string: ad.tag!)!))
                } else {
                    //midroll
                    //  adsArray.addObject(DVVideoPlayBreak.playBreakAtTimeFromStart(CMTimeMake(Int64(ad.offset!),1), withAdTemplateURL: NSURL(string: ad.tag!)!))
                }
            }
        }
        else
        {
            adsArray = NSMutableArray()
        }
        print(adsArray)
        return adsArray
    }
    
    func removeAdsAndPlayVideo() {
        print("notification recieved - no ads to play")
        self.removeAdPlayer()
        self.setupVideoPlayer()
    }
    
}

struct adObject
{
    var offset: Double?
    var tag: String?
}
