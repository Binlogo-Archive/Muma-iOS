//
//  MumaMedia.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

func metaDataStringOfImage(_ image: UIImage, needBlurThumbnail: Bool) -> String? {
    
    let metaDataInfo: [String: AnyObject]
    
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    
    let thumbnailWidth: CGFloat
    let thumbnailHeight: CGFloat
    
    if imageWidth > imageHeight {
        thumbnailWidth = min(imageWidth, MumaConfig.MetaData.thumbnailMaxSize)
        thumbnailHeight = imageHeight * (thumbnailWidth / imageWidth)
    } else {
        thumbnailHeight = min(imageHeight, MumaConfig.MetaData.thumbnailMaxSize)
        thumbnailWidth = imageWidth * (thumbnailHeight / imageHeight)
    }
    
    let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
    
    if let thumbnail = image.navi_resizeToSize(thumbnailSize, withInterpolationQuality: CGInterpolationQuality.High) {
        
        if needBlurThumbnail {
            
            metaDataInfo = [
                MumaConfig.MetaData.imageWidth: imageWidth,
                MumaConfig.MetaData.imageHeight: imageHeight,
            ]
            
        } else {
            
            let data = UIImageJPEGRepresentation(thumbnail, 0.7)
            
            let string = data!.base64EncodedStringWithOptions(NSData.Base64EncodingOptions(rawValue: 0))
            
            print("image thumbnail string length: \(string.lengthOfBytesUsingEncoding(String.Encoding.utf8))\n")
            
            metaDataInfo = [
                MumaConfig.MetaData.imageWidth: imageWidth,
                MumaConfig.MetaData.imageHeight: imageHeight,
                MumaConfig.MetaData.thumbnailString: string,
            ]
        }
        
    } else {
        metaDataInfo = [
            MumaConfig.MetaData.imageWidth: imageWidth,
            MumaConfig.MetaData.imageHeight: imageHeight
        ]
    }
    
    var metaDataString: String? = nil
    if let metaData = try? JSONSerialization.data(withJSONObject: metaDataInfo, options: []) {
        metaDataString = NSString(data: metaData, encoding: String.Encoding.utf8) as? String
    }
    
    return metaDataString
}
