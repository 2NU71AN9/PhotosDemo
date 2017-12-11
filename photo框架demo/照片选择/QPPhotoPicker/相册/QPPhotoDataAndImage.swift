
//
//  QPPhotoDataAndImage.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/7.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class QPPhotoDataAndImage: NSObject {
    class func getImagesAndDatas(photos:[PHAsset], imageData:@escaping(_ phtotArr: [QPPhotoImageModel]?)->Void){
        var smallImageArr = [UIImage]()
        var bigImageArr = [UIImage]()
        var DataArr = [Data]()
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .highQualityFormat
        smallOptions.resizeMode = .fast
        
        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .highQualityFormat
        bigOptions.resizeMode = .exact
        
        let imageManeger = PHImageManager()
        var modelArray = [QPPhotoImageModel]()
        for asset in photos {
            //大图 
            let size = CGSize.init(width: asset.pixelWidth, height: asset.pixelHeight)
            let model = QPPhotoImageModel()
            model.asset = asset
            imageManeger.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: bigOptions, resultHandler: { (image, info) in
                if image != nil{
                    model.bigImage = image!
                    bigImageArr.append(image!)
                    imageManeger.requestImage(for: asset, targetSize: CGSize.init(width: 50, height: 50), contentMode: .aspectFit, options: smallOptions, resultHandler: { (image, info) in
                        if image != nil{
                            model.smallImage = image!
                            smallImageArr.append(image!)
                            imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { (data, str, imageOrientation, info) in
                                if data != nil{
                                    model.imageData = data!
                                    DataArr.append(data!)
                                    modelArray.append(model)
                                    if modelArray.count == photos.count{
                                        DispatchQueue.main.async {
                                            imageData(modelArray)
                                        }
                                    }
                                    
                                }
                            })
                            
                        }
                    })

                }
            })


        }
        

    }
}
