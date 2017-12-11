//
//  SLPhotoBaseViewController.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/15.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit

class SLPhotoBaseViewController: UIViewController {

    var complete: (([PhotoModel], Bool) -> Void)?
    
    convenience init(complete: @escaping (([PhotoModel], Bool) -> Void)) {
        self.init()
        self.complete = complete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    func showCancleBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.done, target: self, action: .rightBarButtonCancleChick)
    }
    
    @objc func cancle() {
        self.dismiss(animated: true, completion: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /**
     是否到达最大可选数量
     
     - parameter photos: 已选中的数组
     
     - returns: true 已到最大值
     */
    func checkMaxCount(_ photos: [PhotoModel]) -> Bool {
        
        let topVc = self.navigationController?.childViewControllers.first as! SLAlbumViewController
        
        if photos.count < topVc.maxPhotos { return false}
        
        let errorMessage = "最多选择\(topVc.maxPhotos)张"
        
        let alterVc = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        
        let cancleAction = UIAlertAction(title: "确定", style: .cancel) { (action) in
            print(action.title ?? "标题")
        }
        
        alterVc.addAction(cancleAction)
        
        self.present(alterVc, animated: true, completion: nil)
        
        return true
    }
    
    /// 相册内无图片时显示的label
    lazy var authorLable: UILabel = {
        let deniedLable = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        deniedLable.numberOfLines = 0
        deniedLable.textAlignment = .center
        deniedLable.textColor = UIColor.black
        deniedLable.center = view.center
        return deniedLable
    }()
    
}
private extension Selector {
    static let rightBarButtonCancleChick = #selector(SLPhotoBaseViewController.cancle)
}

//MARK: 导航控制器
class SLPhotoNavgation: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor.black
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

