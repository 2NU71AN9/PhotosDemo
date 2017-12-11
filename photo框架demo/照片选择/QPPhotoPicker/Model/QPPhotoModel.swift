//
//  QPPhotoModel.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class QPPhotoModel {
    var fetchResult: PHFetchResult<PHObject>!
    var assetType: PHAssetCollectionSubtype!
    var name: String!
    
    init(result: PHFetchResult<PHObject>,label: String?, assetType: PHAssetCollectionSubtype){
        self.fetchResult = result
        self.name = label
        self.assetType = assetType
    }
}
