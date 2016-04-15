//
//  MumaAsset.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import AVFoundation

func thumbnailImageOfVideoInVideoURL(videoURL: NSURL) -> UIImage? {
    
    let asset = AVURLAsset(URL: videoURL, options: [:])
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    imageGenerator.appliesPreferredTrackTransform = true
    
    var actualTime: CMTime = CMTimeMake(0, 0)
    
    guard let cgImage = try? imageGenerator.copyCGImageAtTime(CMTimeMakeWithSeconds(0.0, 600), actualTime: &actualTime) else {
        return nil
    }
    
    let thumbnail = UIImage(CGImage: cgImage)
    
    return thumbnail
}
