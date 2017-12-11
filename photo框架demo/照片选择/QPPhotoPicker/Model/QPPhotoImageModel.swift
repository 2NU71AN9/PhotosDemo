//
//  QPPhotoImageModel.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/7.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class QPPhotoImageModel: NSObject {
    
    var smallImage: UIImage?
    var bigImage: UIImage?
    var imageData: Data?
    var asset: PHAsset?
    
    
    func initSelf(asset: PHAsset) {
        let imageManeger = PHImageManager()
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .opportunistic
        smallOptions.resizeMode = .fast
        
        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .opportunistic
        bigOptions.resizeMode = .exact
        
        self.asset = asset
        //大图
        let size = CGSize.init(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManeger.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode(rawValue: 0)!, options: bigOptions, resultHandler: { (image, info) in
            if image != nil{
                self.bigImage = image!
            }
        })
        //小图
        imageManeger.requestImage(for: asset, targetSize: CGSize.init(width: 50, height: 50), contentMode: PHImageContentMode(rawValue: 0)!, options: smallOptions, resultHandler: { (image, info) in
            if image != nil{
                self.smallImage = image!
            }
        })
        //Data
        imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { (data, str, imageOrientation, info) in
            if data != nil{
                self.imageData = data!
            }
        })
    }
}
