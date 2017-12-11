//
//  PhotoImageManager.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class PhotoImageManager: PHCachingImageManager {
    
    override init() {super.init()}
    
    func getPhotoByMaxSize(asset: PHObject, size: CGFloat, completion: @escaping (UIImage?, Data?, [NSObject : AnyObject]?)->Void){
        
        let maxSize = size > PhotoPickerConfig.PreviewImageMaxFetchMaxWidth ? PhotoPickerConfig.PreviewImageMaxFetchMaxWidth : size
        if let asset = asset as? PHAsset {
            
            let factor = CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth)
            let scale = UIScreen.main.scale
            let pixcelWidth = maxSize * scale
            let pixcelHeight = CGFloat(pixcelWidth) * factor
            
            self.requestImage(for: asset, targetSize: CGSize(width:pixcelWidth, height: pixcelHeight), contentMode: .aspectFit, options: nil, resultHandler: { (image, info) -> Void in
                
                if let info = info as? [String:AnyObject] {
                    let canceled = info[PHImageCancelledKey] as? Bool
                    let error = info[PHImageErrorKey] as? NSError
                    
                    if canceled == nil && error == nil && image != nil {
                        var data = UIImageJPEGRepresentation(image!, 1)
                        if data == nil{
                            data = UIImagePNGRepresentation(image!)
                        }
                        completion(image, data, info as [NSObject : AnyObject]?)
                    }
                    
                    //从iCloud下载
                    let isCloud = info[PHImageResultIsInCloudKey] as? Bool
                    if isCloud != nil && image == nil {
                        let options = PHImageRequestOptions()
                        options.isNetworkAccessAllowed = true
                        self.requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, oritation, info) -> Void in
                            
                            if let data = data {
                                let resultImage = UIImage(data: data, scale: 0.1)
                                completion(resultImage, data, info as [NSObject : AnyObject]?)
                            }
                        })
                    }
                }
            })
        }
    }

}
