//
//  SLPhotosManager.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/15.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import Photos
import Foundation

final class SLPhotosManager {
    
    /// 是否授权
    ///
    /// - Returns: 是或否
    class func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized ||
            PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
    /// 创建相册
    ///
    /// - Parameters:
    ///   - name: 要创建的相册名称
    ///   - complete: 完成的闭包,里面有创建好的相册
    class func createAlbum(name: String? = Bundle.main.infoDictionary?["CFBundleName"] as? String, complete: @escaping (PHAssetCollection?) -> Void) {
        
        guard let name = name else { return }
        
        //获取所有的自定义相册（保证相册只被创建一个）
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        //查找当前name对应的自定义相册
        for i in 0 ..< collections.count {
            let clet = collections[i]
            if clet.localizedTitle == name {
                complete(clet)
                return
            }
        }
        
        //当前name对应的自定义相册没有被创建过
        var createdCollectionID: String = ""
        var clet: PHAssetCollection?
        
        PHPhotoLibrary.shared().performChanges({
            createdCollectionID =  PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name).placeholderForCreatedAssetCollection.localIdentifier
        }, completionHandler: { (isSuccess, error) in
            print("创建相册\(name, isSuccess)")
            clet = isSuccess ? PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [createdCollectionID], options: nil).firstObject : nil
            complete(clet)
        })
    }
    
    /// 创建图片Assets
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - complete: 完成的闭包,里面有创建好的图片Assets
    class func createImageAssets(_ image: UIImage, complete: @escaping (PHObjectPlaceholder?) -> Void) {
        var imageAssest: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            imageAssest = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset
        }) { (isSuccess, error) in
            print("创建图片\(isSuccess)")
            complete(imageAssest)
        }
    }
}

// MARK: - 保存图片相关
extension SLPhotosManager {
    
    /// 保存图片到系统默认相册
    ///
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - complete: 完成的闭包
    class func savePhotoToDefaultAlbum(_ image: UIImage, complete: @escaping (Bool, Error?) -> Void) {
        
        if !isAuthorized() {
            complete(false, nil)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (isSuccess, error) in
            print("保存图片到系统默认相册\(isSuccess)")
            complete(isSuccess, error)
        }
    }
    
    /// 保存图片到自定义相册
    ///
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - albumName: 要保存到的相册名称
    ///   - complete: 完成的闭包
    class func savePhotoToCustomAlbum(_ image: UIImage, albumName: String = Bundle.main.infoDictionary?["CFBundleName"] as! String, complete: @escaping (Bool, Error?) -> Void) {
        
        if !isAuthorized() {
            complete(false, nil)
            return
        }
        
        createAlbum(name: albumName) { clet in

            guard let clet = clet else { return }

            self.createImageAssets(image) { imageAssets in

                guard let imageAssets = imageAssets else { return }

                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCollectionChangeRequest(for: clet)
                    request?.addAssets([imageAssets] as NSArray)
                }) { (isSuccess, error) in
                    complete(isSuccess, error)
                    print("保存图片到\(String(describing: albumName))相册\(isSuccess)")
                }
            }
        }
    }
}

// MARK: - 选择图片相关
extension SLPhotosManager {

    /// 相册选择图片
    ///
    /// - Parameters:
    ///   - baseVC: 从哪个页面跳转
    ///   - count: 数量
    ///   - complete: 完成闭包
    class func choicePhotoFromAlbum(_ baseVC: UIViewController, count: Int, complete: @escaping ([UIImage]) -> Void) {
        
        let rootVc = SLAlbumViewController { (photos, isOriginal) in
            
            var imageList = [UIImage]()
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = .none // 对请求的图像怎样缩放
            requestOptions.isSynchronous = true // 同步执行
            
            for photoAss in photos {
                PHImageManager.default().requestImage(for: photoAss.asset!, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions, resultHandler: { (image, imageDic) in
                    image != nil ? imageList.append(image!) : ()
                })
            }
            complete(imageList)
        }
        rootVc.maxPhotos = count
        baseVC.present(SLPhotoNavgation(rootViewController: rootVc), animated: true, completion: nil)
    }
}

