//
//  AnalyticsManager.swift
//  Zype
//
//  Created by Andy Zheng on 1/24/18.
//  Copyright © 2018 Eugene Lizhnyk. All rights reserved.
//

import Foundation

class AnalyticsManager: NSObject {
    // MARK: - Properties
    public static let sharedInstance = AnalyticsManager()

    // MARK: - reset
    open func reset() {
        AKAMMediaAnalytics_Av.deinitMASDK()
    }
    
    // MARK: - track video playback
    open func trackPlayer(withConfigUrl url: URL, withPlayer player: AVPlayer, withCustomData data: Dictionary<String, String>){
        AKAMMediaAnalytics_Av.initWithConfigURL(url)
        AKAMMediaAnalytics_Av.process(withAVPlayer: player)
        
        for (key, value) in data {
            AKAMMediaAnalytics_Av.setData(key, value: value)
        }
    }
    
    open func trackPause(){
        
    }
    
    open func trackError(_ error: String){
        AKAMMediaAnalytics_Av.avPlayerPlaybackCompleted(error)
        AKAMMediaAnalytics_Av.deinitMASDK()
    }
    
    open func trackStop() {
        AKAMMediaAnalytics_Av.avPlayerPlaybackCompleted()
        AKAMMediaAnalytics_Av.deinitMASDK()
    }
    
}
