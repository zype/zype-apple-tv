//
//  AdProtocolDelegate.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/16/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AdHelperProtocol: class {
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray
    func playAds(adsArray: NSMutableArray, url: NSURL)
    func setupAdTimer()
    func adTimerDidFire()
    func addAdLabel()
    func nextAdPlayer()
    func removeAdTimer()
    func removeAdPlayer()
    func observeTimerForMidrollAds()
    func shouldPlayMidrollAds()
    func removePeriodicTimeObserver()
}

extension PlayerVC: AdHelperProtocol {
    
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray {
        var adsArray = NSMutableArray()
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            if let advertising = body["advertising"] as? NSDictionary{
                let schedule = advertising["schedule"] as? NSArray
                self.adsData = [adObject]()
                
                if (schedule != nil) {
                    for i in 0..<schedule!.count {
                        let adDict = schedule![i] as! NSDictionary
                        let ad = adObject(offset: adDict["offset"] as? Double, tag:adDict["tag"] as? String)
                        self.adsData.append(ad)
                    }
                }
            }
        }
        _ = self.adsData.sorted(by: { $0.offset! < $1.offset! })
        
        if self.adsData.count > 0 {
            let prerollAds = self.adsData.filter({ $0.offset == 0 })
            let prerollAd = prerollAds[0]
            adsArray.add(DVVideoPlayBreak.playBreakBeforeStart(withAdTemplateURL: URL(string: prerollAd.tag!)))
        }
        else {
            adsArray = NSMutableArray()
        }
        return adsArray
    }
    
    func playAds(adsArray: NSMutableArray, url: NSURL) {
        self.adPlayer = DVIABPlayer()
        
        let screenSize = UIScreen.main.bounds
        self.playerView = DVPlayerView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height))
        
        self.adPlayer!.playerLayer = self.playerView?.layer as! AVPlayerLayer
        (self.playerView?.layer as! AVPlayerLayer).player = self.adPlayer
        self.view.addSubview(self.playerView!)
        
        let adPlaylist = DVVideoMultipleAdPlaylist()
        
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
    
    func setupAdTimer() {
        self.adTimer = Timer.scheduledTimer(timeInterval: self.adPlayer!.currentInlineAd.skippableDuration,
                                            target: self,
                                            selector: #selector(PlayerVC.adTimerDidFire),
                                            userInfo: nil, repeats: false)
    }
    
    func adTimerDidFire() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        
        let screenSize = UIScreen.main.bounds
        let skipView = UIView(frame: CGRect(x: screenSize.width,
                                            y: screenSize.height - 300,
                                            width: 400,
                                            height: 200))
        skipView.tag = 1001
        skipView.backgroundColor = UIColor.black
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRect(x: skipView.bounds.size.width - 250,
                                              y: skipView.bounds.size.height - 200,
                                              width: 100,
                                              height: 100))
        skipLabel.text = "Skip"
        skipLabel.font = UIFont.systemFont(ofSize: 30)
        skipLabel.textColor = UIColor.white
        skipLabel.textAlignment = .center
        skipView.addSubview(skipLabel)
        self.view.addSubview(skipView)
        self.view.bringSubview(toFront: skipView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            skipView.frame = CGRect(x: screenSize.width - 400,
                                    y: screenSize.height - 300,
                                    width: 400,
                                    height: 100)
        }) { (done) in
            self.isSkippable = true
        }
    }
    
    func addAdLabel() {
        let screenSize = UIScreen.main.bounds
        let skipView = UIView(frame: CGRect(x: screenSize.width-250,
                                            y: 30,
                                            width: 250,
                                            height: 40))
        skipView.tag = 1002
        skipView.backgroundColor = UIColor.black
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 100,
                                              height: 40))
        skipLabel.text = "Ad"
        skipLabel.font = UIFont.systemFont(ofSize: 30)
        skipLabel.textColor = UIColor.white
        skipLabel.textAlignment = .center
        skipView.addSubview(skipLabel)
        self.playerView?.addSubview(skipView)
    }
    
    func nextAdPlayer() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        if (self.adPlayer?.adsQueue.count)! > 0 {
            self.adPlayer?.finishCurrentInlineAd(self.adPlayer?.currentInlineAdPlayerItem)
        }
        else {
            self.removeAdPlayer()
            self.setupVideoPlayer()
        }
    }
    
    func removeAdTimer() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        if self.adTimer != nil {
            self.adTimer.invalidate()
        }
    }
    
    func removeAdPlayer() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
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
    
    func observeTimerForMidrollAds() {
        guard self.adsData.count > 0 else { // no ads to observe
            self.removePeriodicTimeObserver()
            return
        }
        
        if self.adsData.count == 1 {
            return
        }
        
        let adTimer = self.playerController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) { (time) in
            guard let offsetMSeconds = self.adsData[0].offset else { return }
            let offset = Int(offsetMSeconds) / 1000
            
            if offset == 0 { // remove preroll
                self.adsData.remove(at: 0)
                return
            }
            
            let currentTime = Int(CMTimeGetSeconds(time))
            
            if currentTime > offset + 4 { // user seeked passed this ad - 4 seconds to compensate for the + 2 below
                self.adsData.remove(at: 0)
            }
            if currentTime == offset + 2 { // 2 seconds added to offset to save most relevant 10 second chunk
                self.shouldPlayMidrollAds()
            }
        }
        self.timeObserverToken = adTimer
    }
    
    func shouldPlayMidrollAds() {
        let timeStamp = self.playerController.player?.currentTime().seconds
        self.userDefaults.setValue(timeStamp, forKey: "\(self.currentVideo.getId())")
        
        if self.playerController.player != nil {
            self.playerController.player?.pause()
        }
        
        self.playAds(adsArray: self.adsArray!, url: self.url!)
        self.adsData.remove(at: 0)
        self.isResuming = true
        self.removePeriodicTimeObserver()
    }
    
    func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            self.playerController.player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
}

struct adObject {
    var offset: Double?
    var tag: String?
}
