//
//  QPPhotoFetchOptions.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class QPPhotoFetchOptions: PHFetchOptions {
    
    override init() {
        super.init()
        //对相册进行一个排序，key为creationDate: 按照时间排序
        self.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        self.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    }
    
}
