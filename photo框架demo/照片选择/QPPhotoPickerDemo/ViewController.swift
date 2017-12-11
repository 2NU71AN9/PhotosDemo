//
//  ViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.


//  联系方式:
//  邮箱: gqpfsnh@163.com
//  QQ: 328420297
//  微信: gqp328420297

import UIKit
import Photos
/* 如果需要适配 iOS 10，请在info.plist中加入如下字段
 * NSCameraUsageDescription -->  我们需要使用您的相机
 * NSPhotoLibraryUsageDescription --> 我们需要访问您的相册
 * 如不添加该字段，在iOS 10环境下会直接崩溃
 */

class ViewController: UIViewController {
    //声明
    var picker: QPPhotoPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        QPPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //初始化并添加
    /* 第一个参数，当前控制器
     * 第二个参数，照片选择器的frame
     */
    func QPPicker(){
        picker = QPPhotoPickerView.init(controller: self, frame: CGRect.init(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 200))
        //选取照片最大数量
        picker?.maxNum = 9
        self.view.addSubview(picker!)
    }
    //上传
    func upLoadData(){
        var dataArray = [Data]()
        for model in (picker?.QPPhotos)! {
            dataArray.append(model.imageData!)
        }
        //上传Data数组
    }
    
}

