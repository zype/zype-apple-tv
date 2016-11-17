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

class PlayerVC: UIViewController, DVIABPlayerDelegate
{
    var adPlayer: DVIABPlayer?
    var playerLayer = AVPlayerLayer()
    var playerItem: AVPlayerItem!
    var playerController = AVPlayerViewController()
    var playerURL = NSURL()
    var playerView: DVPlayerView?
    var isSkippable = false
    
    var playlist: Array<VideoModel>? = nil
    var currentVideo: VideoModel!
    var adTimer: NSTimer!
    
    var adsData: [adObject] = [adObject]()
    
    var currentTime : CMTime!
    
    deinit {
        print("Destroying")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.play(self.currentVideo)
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?)
    {
        print("presses began \(presses.first?.type)")
        //type == .Select
        if let type = presses.first?.type where type == .PlayPause
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
        else if let type = presses.first?.type where type == .Select
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
        }/* else if let type = presses.first?.type where type == .Menu
         {
         print("menu clicked")
         NSNotificationCenter.defaultCenter().removeObserver(self)
         if self.adPlayer != nil
         {
         self.adPlayer?.pause()
         }
         if self.playerController.player != nil
         {
         self.playerController.player?.pause()
         }
         
         }*/

    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?)
    {
        super.pressesEnded(presses, withEvent: event)
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
    
    func play(model: VideoModel)
    {
        model.getVideoObject(.kVimeoHls, completion: {[unowned self] (playerObject: VideoObjectModel?, error: NSError?) in
            if let _ = playerObject, let videoURL = playerObject?.videoURL, let url = NSURL(string: videoURL) where error == nil
            {
                let adsArray = self.getAdsFromResponse(playerObject)
                
                self.playerURL = url
                
                if adsArray.count == 0
                {
                    self.setupVideoPlayer()
                }
                else
                {
                    self.adPlayer = DVIABPlayer()
                    
                    let screenSize = UIScreen.mainScreen().bounds
                    self.playerView = DVPlayerView(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
                    
                    self.adPlayer!.playerLayer = self.playerView?.layer as! AVPlayerLayer
                    (self.playerView?.layer as! AVPlayerLayer).player = self.adPlayer
                    self.view.addSubview(self.playerView!)
                    
                    let adPlaylist = DVVideoMultipleAdPlaylist()
                    
                    print(adsArray)
                    
                    adPlaylist.playBreaks = NSArray(array: adsArray.copy() as! [AnyObject]) as [AnyObject]
                    self.adPlayer!.adPlaylist = adPlaylist
                    self.adPlayer!.delegate = self
                    
                    self.playerItem = AVPlayerItem(URL: url)
                    self.playerItem.addObserver(self, forKeyPath: "status", options: [.New], context: nil)
                    self.adPlayer!.contentPlayerItem = self.playerItem
                    self.adPlayer!.replaceCurrentItemWithPlayerItem(self.playerItem)
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.setupAdTimer), name: "setupAdTimer", object: nil)
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.removeAdTimer), name: "removeAdTimer", object: nil)
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.addAdLabel), name: "adPlaying", object: nil)
                    
                    //this is called when there are ad tags, but they don't return any ads
                     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.removeAdsAndPlayVideo), name: "noAdsToPlay", object: nil)
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.adPlayer!.contentPlayerItem)
                }
                
                self.currentVideo = model
                
            }
            else
            {
                self.navigationController?.popViewControllerAnimated(true)
                displayError(error)
            }
            })
    }
    
    func contentDidFinishPlaying(notification: NSNotification)
    {
        print("content did finish playing")
        // Make sure we don't call contentComplete as a result of an ad completing.
        if ((notification.object as! AVPlayerItem) == self.playerController.player!.currentItem)
        {
            self.playerController.removeFromParentViewController()
            self.playerController.view.removeFromSuperview()
            self.playerController.player?.replaceCurrentItemWithPlayerItem(nil)
            self.playerController = AVPlayerViewController()
            
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
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        print(self.adPlayer?.status)
        if self.adPlayer!.status == .ReadyToPlay
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.adPlayer!.play()
                })
                
            }
        }
        else if self.adPlayer!.status == .Failed
        {
            print("ad player failed")
            print(self.adPlayer!.currentItem?.error)
            
            self.removeAdPlayer()
            
            self.setupVideoPlayer()
        }
        else
        {
            print("some other status")
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
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
        self.adPlayer?.replaceCurrentItemWithPlayerItem(nil)
        self.adPlayer = nil
        self.playerItem = nil
        self.playerView!.removeFromSuperview()
        self.playerView = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        self.adTimer = NSTimer.scheduledTimerWithTimeInterval(self.adPlayer!.currentInlineAd.skippableDuration, target: self, selector: #selector(PlayerVC.adTimerDidFire), userInfo: nil, repeats: false)
    }
    
    func adTimerDidFire()
    {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001)
        {
            viewWithTag.removeFromSuperview()
        }
        let screenSize = UIScreen.mainScreen().bounds
        let skipView = UIView(frame: CGRectMake(screenSize.width,screenSize.height - 300,400,200))
        skipView.tag = 1001
        skipView.backgroundColor = UIColor.blackColor()
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRectMake(skipView.bounds.size.width - 250,skipView.bounds.size.height - 200,100,100))
        skipLabel.text = "Skip"
        skipLabel.font = UIFont.systemFontOfSize(30)
        skipLabel.textColor = UIColor.whiteColor()
        skipLabel.textAlignment = .Center
        skipView.addSubview(skipLabel)
        self.view.addSubview(skipView)
        self.view.bringSubviewToFront(skipView)
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            
            skipView.frame = CGRectMake(screenSize.width - 400,screenSize.height - 300,400,100)
            
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
    func player(player: DVIABPlayer!, shouldPauseForAdBreak playBreak: DVVideoPlayBreak!) -> Bool
    {
        print("should pause for ad break? Yes")
        return true
    }
    
    func player(player: DVIABPlayer!, didFailPlayBreak playBreak:DVVideoPlayBreak!, withError:NSError ) {
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
        let player = AVPlayer(URL: self.playerURL)
        self.playerController.player = player
        self.addChildViewController(self.playerController)
        self.view.addSubview(self.playerController.view)
        self.playerController.view.frame = self.view.frame
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        player.play()
    }
    
    func addAdLabel() {
        print("adding ad label \(self.adsData)")
        
        let screenSize = UIScreen.mainScreen().bounds
        let skipView = UIView(frame: CGRectMake(screenSize.width-250,30,250,40))
        skipView.tag = 1002
        skipView.backgroundColor = UIColor.blackColor()
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRectMake(0,0,100,40))
        skipLabel.text = "Ad"
        skipLabel.font = UIFont.systemFontOfSize(30)
        skipLabel.textColor = UIColor.whiteColor()
        skipLabel.textAlignment = .Center
        skipView.addSubview(skipLabel)
        self.playerView?.addSubview(skipView)
        //self.view.bringSubviewToFront(skipView)
    }
    
    func getAdsFromResponse(playerObject: VideoObjectModel?) -> NSMutableArray {
        var adsArray = NSMutableArray()
        print(playerObject?.json)
        if let body = playerObject?.json?["response"]?["body"]
        {
            let schedule = body?["advertising"]??["schedule"] as? NSArray
            
            self.adsData = [adObject]()
            
            if (schedule != nil) {
                for i in 0..<schedule!.count
                {
                    let adDict = schedule![i]
                    let ad = adObject(offset: adDict["offset"] as? Double, tag:adDict["tag"] as? String)
                    self.adsData.append(ad)
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
                    adsArray.addObject(DVVideoPlayBreak.playBreakBeforeStartWithAdTemplateURL(NSURL(string: ad.tag!)!))
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
