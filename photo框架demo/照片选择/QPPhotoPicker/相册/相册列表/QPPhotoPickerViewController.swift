

//
//  QPPhotoPickerViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

enum PageType{
    case List           //相册列表
    case RecentAlbum    //最近添加
    case AllAlbum       //用户自定义相册
}
protocol PhotoPickerControllerDelegate: class{
    func onImageSelectFinished(images: [PHAsset])
}

class QPPhotoPickerViewController: UINavigationController {
    //照片最大数量
    var imageMaxSelectedNum = 9
    //已选照片数
    var alreadySelectedImageNum = 0
    //代理，获取已选照片的数组
    weak var imageSelectDelegate: PhotoPickerControllerDelegate?
    //需要回传的值
    var AssetArr = [PHAsset].init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //初始化，根据初始化类型判断是进入相册或者是照片页
    init(type: PageType){
        //导航下根控制器为相册
        let RootViewController = QPPhotoListViewController(style: .plain)
        super.init(rootViewController: RootViewController)
        //根据状态，自定义进入时类型
        if type == .RecentAlbum || type == .AllAlbum {
            let currentType = type == .RecentAlbum ? PHAssetCollectionSubtype.smartAlbumRecentlyAdded : PHAssetCollectionSubtype.smartAlbumUserLibrary
            //根据类型获取相册数组
            let results = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype:currentType, options: nil)
            if results.count > 0 {
                //如果进入照片页，则取第一个相册中的所有元素
                if let model = self.getModel(collection: results[0]) {
                    if model.count > 0 {
                        //初始化照片页
                        let layout = QPPhotoCollectionViewController.configCustomCollectionLayout()
                        let controller = QPPhotoCollectionViewController(collectionViewLayout: layout)
                        controller.fetchResult = model as? PHFetchResult<PHObject>
                        self.pushViewController(controller, animated: false)
                    }
                }
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    private func getModel(collection: PHAssetCollection) -> PHFetchResult<PHAsset>?{
        let option = QPPhotoFetchOptions.init()
        //将相册中的元素进行时间排序
        let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
        //只返回有照片的相册
        if fetchResult.count > 0 {
            return fetchResult
        }
        return nil
    }
    
    func imageSelectFinish(){
        if self.imageSelectDelegate != nil {
            self.dismiss(animated: true, completion: {
                self.imageSelectDelegate?.onImageSelectFinished(images: self.AssetArr)
            })
        }
    }


}
