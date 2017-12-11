//
//  PhotoPickerConfig.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import Foundation
import UIKit
//可以手动改变的常量
class PhotoPickerConfig {
    static let ScreenWidth = UIScreen.main.bounds.width
    static let ScreenHeight = UIScreen.main.bounds.height
    //tableView的RowHeight
    static let AlbumTableViewCellHeight: CGFloat = 90.0
    // collceiont cell padding
    static let MinimumInteritemSpacing: CGFloat = 5
    // image total per line
    static let ColNumber: CGFloat = 4
    
    // fethch single large image max width
    static let PreviewImageMaxFetchMaxWidth:CGFloat = 600

    // button secelt image done title
    static let ButtonDone = "完成"
    
    // button confirm title
    static let ButtonConfirmTitle  = "确定"
    
    // message when select number more than the max number
    static let ErrorImageMaxSelect = "图片选择最多超过不能超过#张"
    
    // preview view bar background color
    static let PreviewBarBackgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)

    // button green tin color
    static let GreenTinColor = UIColor(red: 7/255, green: 179/255, blue: 20/255, alpha: 1)
    
    //选择器单元格边长
    static let selectWidth = 80
}
