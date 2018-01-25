//
//  AnalyticsProtocolDelegate.swift
//  Zype
//
//  Created by Andy Zheng on 1/24/18.
//  Copyright © 2018 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AnalyticsHelperProtocol: class {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> Dictionary<String, String>
}

extension PlayerVC: AnalyticsHelperProtocol {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> Dictionary<String, String> {
        
        var analyticsInfo = [String:String]()
        
        if let consumer = ZypeAppleTVBase.sharedInstance.consumer {
            analyticsInfo["consumerId"] = consumer.ID
        }
        
        if let video = playerObject?.json?["response"]?["video"] as? NSDictionary {
            if let title = video["title"] as? String {
                analyticsInfo["title"] = title
            }
        }
        
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            
            if let analytics = body["analytics"] as? NSDictionary {
                
                if let beacon = analytics["beacon"] as? String {
                    analyticsInfo["beacon"] = beacon
                }
                
                if let dimensions = analytics["dimensions"] as? NSDictionary {
                    if let videoId = dimensions["video_id"] as? String {
                        analyticsInfo["videoId"] = videoId
                    }
                    
                    if let siteId = dimensions["site_id"] as? String {
                        analyticsInfo["siteId"] = siteId
                    }
                    
                    if let playerId = dimensions["player_id"] as? String {
                        analyticsInfo["playerId"] = playerId
                    }
                    
                    if let device = dimensions["device"] as? String {
                        analyticsInfo["deviceType"] = device
                    }
                }
            }
        }
        
        return analyticsInfo
    }
}
