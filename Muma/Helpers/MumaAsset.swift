//
//  MumaAsset.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit
import AVFoundation

func thumbnailImageOfVideoInVideoURL(_ videoURL: URL) -> UIImage? {
    
    let asset = AVURLAsset(url: videoURL, options: [:])
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    imageGenerator.appliesPreferredTrackTransform = true
    
    var actualTime: CMTime = CMTimeMake(0, 0)
    
    guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(0.0, 600), actualTime: &actualTime) else {
        return nil
    }
    
    let thumbnail = UIImage(cgImage: cgImage)
    
    return thumbnail
}
