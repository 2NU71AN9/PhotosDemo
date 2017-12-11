//
//  SLAlbumModel.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/15.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import Photos

class SLAlbumModel: NSObject {

    var assetCollection: PHAssetCollection?
    var collectionTitle: String?
    var collectionLastImage: UIImage?
    var collectionImageCount: Int = 0
    var collectionVideoCount: Int = 0
    
    convenience init(_ assetResult: PHAssetCollection) {
        self.init()
        
        let result = PHAsset.fetchAssets(in: assetResult, options: nil)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        
        if let asset = result.lastObject {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                self.collectionLastImage = image
            })
        }else{
            collectionLastImage = UIImage(named: "place_icon")
        }
        collectionImageCount = result.countOfAssets(with: .image)
        collectionVideoCount = result.countOfAssets(with: .video)
        collectionTitle = assetResult.localizedTitle?.chinese()
        assetCollection = assetResult
    }
}

extension String {
    
    /// 相册英文名称对应的中文
    ///
    /// - Returns: String
    func chinese() -> String {
        var name: String = ""
        
        switch self {
        case "Slo-mo":
            name = "慢动作"
        case "Recently Added":
            name = "最近添加"
        case "Favorites":
            name = "个人收藏"
        case "Recently Deleted":
            name = "最近删除"
        case "Videos":
            name = "视频"
        case "All Photos":
            name = "所有照片"
        case "Selfies":
            name = "自拍"
        case "Screenshots":
            name = "屏幕快照"
        case "Camera Roll":
            name = "相机胶卷"
        case "Panoramas":
            name = "全景照片"
        case "Hidden":
            name = "已隐藏"
        case "Time-lapse":
            name = "延时拍摄"
        case "Bursts":
            name = "连拍快照"
        case "Depth Effect":
            name = "景深效果"
        default:
            name = self
        }
        return name
    }
}

class PhotoModel: NSObject {
    
    var asset: PHAsset?
    /// 是否选中
    var isSelect: Bool = false
    
}
