//
//  AdProtocolDelegate.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/16/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase
import AdSupport

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
    func playMidrollAds()
    func removePeriodicTimeObserver()
}

extension PlayerVC: AdHelperProtocol {
    
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray {
        let adsArray = NSMutableArray()
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            if let advertising = body["advertising"] as? NSDictionary{
                let schedule = advertising["schedule"] as? NSArray
                self.adsData = [adObject]()
                
                if (schedule != nil) {
                    for i in 0..<schedule!.count {
                        let adDict = schedule![i] as! NSDictionary
                        
                        let tag = replaceAdMacros((adDict["tag"] as? String)!)
                        let ad = adObject(offset: adDict["offset"] as? Double, tag: tag)
                        
                        self.adsData.append(ad)
                    }
                }
            }
        }
        self.adsData = self.adsData.sorted(by: { $0.offset! > $1.offset! }) // sort for midroll
        
        guard adsData.count > 0 else { return adsArray }
        
        adsArray.add(DVVideoPlayBreak.playBreakBeforeStart(withAdTemplateURL: URL(string: adsData.last!.tag!)))
        
        return adsArray
    }
    
    fileprivate func replaceAdMacros(_ tag: String) -> String {
        var string = tag
        
        let uuid = ZypeAppSettings.sharedInstance.deviceId()
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        let appBundle = Bundle.main.bundleIdentifier
        let deviceType = 7
        let deviceMake = "Apple"
        let deviceModel = "AppleTV"
        let deviceIfa = ASIdentifierManager.shared().advertisingIdentifier
        let vpi = "mp4"
        let appId = ZypeAppSettings.sharedInstance.deviceId()
        
        string = (string as NSString).replacingOccurrences(of: "[uuid]", with: "\(uuid.encodeUrlQueryParam())")
        string = (string as NSString).replacingOccurrences(of: "[app_name]", with: "\(appName.encodeUrlQueryParam())")
        if let bundle = appBundle {
            string = (string as NSString).replacingOccurrences(of: "[app_bundle]", with: "\(bundle)".encodeUrlQueryParam())
            string = (string as NSString).replacingOccurrences(of: "[app_domain]", with: "\(bundle)".encodeUrlQueryParam())
        }
        string = (string as NSString).replacingOccurrences(of: "[device_type]", with: "\(deviceType)".encodeUrlQueryParam())
        string = (string as NSString).replacingOccurrences(of: "[device_make]", with: "\(deviceMake)".encodeUrlQueryParam())
        string = (string as NSString).replacingOccurrences(of: "[device_model]", with: "\(deviceModel)".encodeUrlQueryParam())
        string = (string as NSString).replacingOccurrences(of: "[device_ifa]", with: "\(deviceIfa)".encodeUrlQueryParam())

        string = (string as NSString).replacingOccurrences(of: "[device_ua]", with: "\(ZypeUserAgentBuilder.buildtUserAgent().userAgent().encodeUrlQueryParam())")

        string = (string as NSString).replacingOccurrences(of: "[vpi]", with: "\(vpi)".encodeUrlQueryParam())
        string = (string as NSString).replacingOccurrences(of: "[app_id]", with: "\(appId)".encodeUrlQueryParam())
        
        return string
    }
    
    func playAds(adsArray: NSMutableArray, url: NSURL) {
        self.adPlayer = DVIABPlayer()
        
        let screenSize = UIScreen.main.bounds
        self.playerView = DVPlayerView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height))
        
        self.adPlayer!.playerLayer = self.playerView?.layer as? AVPlayerLayer
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
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.resumePlayingFromAds), name: NSNotification.Name(rawValue: "noAdsToPlay"), object: nil)
    }
    
    @objc func setupAdTimer() {
        self.adTimer = Timer.scheduledTimer(timeInterval: self.adPlayer!.currentInlineAd.skippableDuration,
                                            target: self,
                                            selector: #selector(PlayerVC.adTimerDidFire),
                                            userInfo: nil, repeats: false)
    }
    
    @objc func adTimerDidFire() {
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
        self.view.bringSubviewToFront(skipView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            skipView.frame = CGRect(x: screenSize.width - 400,
                                    y: screenSize.height - 300,
                                    width: 400,
                                    height: 100)
        }) { (done) in
            self.isSkippable = true
        }
    }
    
    @objc func addAdLabel() {
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
            if let player = self.playerController.player as? ZypeAVPlayer {
                player.resumePlay()
            }
            else {
                self.setupVideoPlayer()
            }
        }
    }
    
    @objc func removeAdTimer() {
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
        let adTimer = self.playerController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main) { (time) in
            guard self.adsData.count > 0 else {
                self.removePeriodicTimeObserver()
                return
            }
            
            guard let offsetMSeconds = self.adsData.last!.offset else { return }
            let offset = Int(offsetMSeconds) / 1000
            let currentTime = Int(CMTimeGetSeconds(time))
            
            if currentTime > offset + 1 { // user seeked passed this ad 
                _ = self.adsData.popLast()
            }
            if currentTime == offset + 1 { // 1 seconds added to offset to save most relevant 10 seconds
                self.playMidrollAds()
            }
        }
        self.timeObserverToken = adTimer
    }

    func playMidrollAds() {
        self.playerController.player?.pause()
        
        //reset ad that should play
        self.adsArray?.removeAllObjects()
        self.adsArray?.add(DVVideoPlayBreak.playBreakBeforeStart(withAdTemplateURL: URL(string: self.adsData.last!.tag!)))
        
        self.playAds(adsArray: self.adsArray!, url: self.url!)
        _ = self.adsData.popLast()
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
