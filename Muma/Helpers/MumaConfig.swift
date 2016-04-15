//
//  MumaConfig.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

class MumaConfig {
    
    static let forcedHideActivityIndicatorTimeInterval: NSTimeInterval = 30
    
    struct MetaData {
        static let audioDuration = "audio_duration"
        static let audioSamples = "audio_samples"
        
        static let imageWidth = "image_width"
        static let imageHeight = "image_height"
        
        static let videoWidth = "video_width"
        static let videoHeight = "video_height"
        
        static let thumbnailString = "thumbnail_string"
        static let blurredThumbnailString = "blurred_thumbnail_string"
        
        static let thumbnailMaxSize: CGFloat = 60
    }
    
    class func clientType() -> Int {
        // TODO: clientType
        #if DEBUG
            return 2
        #else
            return 0
        #endif
    }
}
