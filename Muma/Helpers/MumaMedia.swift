//
//  MumaMedia.swift
//  Muma
//
//  Created by Binboy on 4/15/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import UIKit

func metaDataStringOfImage(image: UIImage, needBlurThumbnail: Bool) -> String? {
    
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
            
            let string = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            print("image thumbnail string length: \(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))\n")
            
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
    if let metaData = try? NSJSONSerialization.dataWithJSONObject(metaDataInfo, options: []) {
        metaDataString = NSString(data: metaData, encoding: NSUTF8StringEncoding) as? String
    }
    
    return metaDataString
}
