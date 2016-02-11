//
//  ZypeFactory.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import Foundation

public enum VideoUrlType {
    case kUnknown
    case kVimeoHls
}

protocol VideoUrl
{
    func getVideoObject(video: VideoModel, completion:(playerObject: VideoObjectModel, error: NSError?) -> Void)
}

class ZypeFactory
{
    static func videoUrl(type: VideoUrlType, restController: ZypeRESTController) -> VideoUrl?
    {
        switch type
        {
            case VideoUrlType.kVimeoHls:
                return VimeoUrl(restController: restController)
            default:
                break
        }
        ZypeLog.error("Unknown Video Type")
        return nil
    }

}