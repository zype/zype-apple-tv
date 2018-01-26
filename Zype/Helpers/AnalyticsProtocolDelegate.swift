//
//  AnalyticsProtocolDelegate.swift
//  Zype
//
//  Created by Andy Zheng on 1/24/18.
//  Copyright © 2018 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AnalyticsHelperProtocol: class {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> (beacon: String, customDimensions: [String: String])
}

extension PlayerVC: AnalyticsHelperProtocol {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> (beacon: String, customDimensions: [String: String]) {
        
        var configUrl = ""
        var customDimensions = [String: String]()
        
        if let consumerId = ZypeAppleTVBase.sharedInstance.consumer?.ID {
            if !consumerId.isEmpty {
                customDimensions["consumerId"] = consumerId
            }
        }
        
        if let video = playerObject?.json?["response"]?["video"] as? NSDictionary {
            if let title = video["title"] as? String {
                customDimensions["title"] = title
            }
        }
        
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            
            if let analytics = body["analytics"] as? NSDictionary {
                
                if let beacon = analytics["beacon"] as? String {
                    configUrl = beacon
                }
                
                if let dimensions = analytics["dimensions"] as? NSDictionary {
                    if let videoId = dimensions["video_id"] as? String {
                        customDimensions["videoId"] = videoId
                    }
                    
                    if let siteId = dimensions["site_id"] as? String {
                        customDimensions["siteId"] = siteId
                    }
                    
                    if let playerId = dimensions["player_id"] as? String {
                        customDimensions["playerId"] = playerId
                    }
                    
                    if let device = dimensions["device"] as? String {
                        customDimensions["deviceType"] = device
                    }
                }
            }
        }
        
        return (beacon: configUrl, customDimensions: customDimensions)
    }
}
