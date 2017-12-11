//
//  QPPhotoPreviewViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos
private let cellID = "QPPhotoPreviewCell"
class QPPhotoPreviewViewController: UIViewController, PhotoPreviewCellDelegate, PhotoPreviewToolbarViewDelegate, PhotoPreviewBottomBarViewDelegate  {
    //当前相册
    var allSelectImage: PHFetchResult<AnyObject>?
    //当前下标
    var currentPage: Int = 1
    
    private var isAnimation = false
    //底部工具条
    private var toolbar: PhotoPreviewToolbarView?
    //顶部工具条
    private var bottomBar: PhotoPreviewBottomBarView?
    
    weak var fromDelegate: PhotoCollectionViewControllerDelegate?
    //当前导航
    var nav: QPPhotoPickerViewController?
    //懒加载collectionView
    lazy var collectionView: UICollectionView = {
        
        self.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width,height: self.view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset = CGPoint.zero
        collectionView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.allSelectImage!.count), height: self.view.bounds.height)
        self.view.addSubview(collectionView)
        
        collectionView.register(QPPhotoPreviewCell.self, forCellWithReuseIdentifier: cellID)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        nav = self.navigationController as? QPPhotoPickerViewController
        collectionView.reloadData()
        configToolbar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 全屏控制器
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        if self.nav == nil {
            nav = self.navigationController as? QPPhotoPickerViewController
        }
        self.collectionView.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * self.view.bounds.width, y: 0), animated: false)
        
        self.changeCurrentToolbar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //每次进入显示当前图像
    func changeCurrentToolbar(){
        let model = self.allSelectImage![self.currentPage] as! PHAsset
        if let _ = nav?.AssetArr.index(of: model){
            self.toolbar!.setSelect(select: true)
        } else {
            self.toolbar!.setSelect(select: false)
        }
    }
    //初始化工具条
    private func configToolbar(){
        self.toolbar = PhotoPreviewToolbarView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        toolbar?.nav = self.nav
        let nav = self.navigationController as! QPPhotoPickerViewController
        toolbar?.maxPhotoNum = nav.imageMaxSelectedNum
        toolbar?.selectNum = nav.alreadySelectedImageNum
        self.toolbar?.delegate = self
        self.toolbar?.sourceDelegate = self
        let positionY = self.view.bounds.height - 50
        self.bottomBar = PhotoPreviewBottomBarView(frame: CGRect(x: 0,y: positionY,width: self.view.bounds.width,height: 50))
        self.bottomBar?.delegate = self
        self.bottomBar?.changeNumber(number: nav.AssetArr.count, animation: false)
        
        self.view.addSubview(toolbar!)
        self.view.addSubview(bottomBar!)
    }

//MARK: - PhotoPreviewBottomBarViewDelegate的协议方法
    func onDoneButtonClicked() {
        if let nav = self.navigationController as? QPPhotoPickerViewController {
            nav.imageSelectFinish()
        }
    }
//MARK: - ToolBar的协议方法
    func onToolbarBackArrowClicked() {
        self.navigationController?.popViewController(animated: true)
        if let delegate = self.fromDelegate {
            delegate.onPreviewPageBack()
        }
    }
    func onSelected(select: Bool) {
        let currentModel = self.allSelectImage![self.currentPage]
        if select {
            nav?.AssetArr.append(currentModel as! PHAsset)
        } else {
            if let index = nav?.AssetArr.index(of: currentModel as! PHAsset){
                nav?.AssetArr.remove(at: index)
            }
        }
        self.bottomBar?.changeNumber(number: (nav?.AssetArr.count)!, animation: true)
    }
//MARK: - PhotoPreviewCellDelegate的协议方法，点击显示或者隐藏导航和工具条
    func onImageSingleTap() {
        if self.isAnimation {
            return
        }
        self.isAnimation = true
        if self.toolbar!.frame.origin.y < 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: { () -> Void in
                self.toolbar!.frame.origin = CGPoint.zero
                var originPoint = self.bottomBar!.frame.origin
                originPoint.y = originPoint.y - self.bottomBar!.frame.height
                self.bottomBar!.frame.origin = originPoint
            }, completion: { (isFinished) -> Void in
                if isFinished {
                    self.isAnimation = false
                }
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: { () -> Void in
                self.toolbar!.frame.origin = CGPoint(x:0, y: -self.toolbar!.frame.height)
                var originPoint = self.bottomBar!.frame.origin
                originPoint.y = originPoint.y + self.bottomBar!.frame.height
                self.bottomBar!.frame.origin = originPoint
                
            }, completion: { (isFinished) -> Void in
                if isFinished {
                    self.isAnimation = false
                }
            })
        }
    }
}
//collectionView的代理方法
extension QPPhotoPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (allSelectImage?.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! QPPhotoPreviewCell
        cell.delegate = self
        if let asset = self.allSelectImage![indexPath.row] as? PHAsset {
            cell.renderModel(asset: asset, bigImage: nil)
        }
        return cell
    }
    //scroView的协议方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.currentPage = Int(offset.x / self.view.bounds.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.changeCurrentToolbar()
    }

}


