//
//  QPPhotoCollectionViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

//cell标识
private let reuseIdentifier = "QPPhotoCell"
protocol PhotoCollectionViewControllerDelegate:class {
    func onPreviewPageBack()
}
class QPPhotoCollectionViewController: UICollectionViewController, PHPhotoLibraryChangeObserver, PhotoCollectionViewCellDelegate, PhotoCollectionViewControllerDelegate {


    //需要显示的照片---从栈中上一个元素赋值
    var fetchResult: PHFetchResult<PHObject>?
    //最下方工具条高度
    private let toolbarHeight: CGFloat = 44.0
    //collectionView的layout
    private var CollectionLayout:UICollectionViewFlowLayout?
    //照片
    let imageManager = PHCachingImageManager()
    //大小
    var assetGridThumbnailSize: CGSize?
    //最下方工具条
    var toolbar: AlbumToolbarView?
    //控制器当前导航
    var nav: QPPhotoPickerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        //获取导航并成为代理
        nav = self.navigationController as? QPPhotoPickerViewController
        setUI()
        // 注册通知，你可以在你的app中时刻监听照片库的状态
        PHPhotoLibrary.shared().register(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.setStatusBarHidden(false, with: .none)

        if self.nav == nil {
            nav = self.navigationController as? QPPhotoPickerViewController
        }
        self.collectionView?.reloadData()
        //给下方工具条重新设值
        self.eventSelectNumberChange(number: (nav?.AssetArr.count)!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //设置collection中元素大小
    func setAssetGridThumbnailSize(){
        if assetGridThumbnailSize == nil {
            //按照屏幕分辨率重设大小
            let scale = UIScreen.main.scale
            let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let size = cellSize.width * scale
            assetGridThumbnailSize = CGSize(width: size, height: size)
        }
    }
    //加载UI，并进行一些设置
    func setUI(){
        configNavigationBar()
        let originFrame = self.collectionView!.frame
        //重新设置collectionView的大小，留出底部工具条的位置
        self.collectionView!.frame = CGRect(x:originFrame.origin.x, y:originFrame.origin.y, width:originFrame.size.width, height: originFrame.height - self.toolbarHeight)
        resetCacheAssets()
        //留出四周空白
        self.collectionView?.contentInset = UIEdgeInsetsMake(
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing
        )
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        configBottomToolBar()
    }
    //设置底部工具条
    private func configBottomToolBar() {
        if self.toolbar != nil {return}
        let width = UIScreen.main.bounds.width
        let positionX = UIScreen.main.bounds.height - self.toolbarHeight
        self.toolbar = AlbumToolbarView(frame: CGRect(x:0,y: positionX,width: width,height: self.toolbarHeight))
        self.toolbar?.delegate = self
        self.view.addSubview(self.toolbar!)
        //存在已选照片时，改变数字
        if (nav?.AssetArr.count)! > 0 {
            self.toolbar?.changeNumber(number: (nav?.AssetArr.count)!)
        }
    }
    
//设置导航
    private func configNavigationBar(){
        //添加取消键
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.eventCancel))
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    func eventCancel(){
        nav?.AssetArr.removeAll()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
// MARK: -   停止缓存请求
    private func resetCacheAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
    }

    
//MARK: - PHPhotoLibraryChangeObserver的协议方法 ----- 相册中有改变的时候
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        if let collectionChanges = changeInstance.changeDetails(for: fetchResult!) {
            
            DispatchQueue.main.async {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
                let collectionView = self.collectionView!
                
                if !(collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves) {
                    collectionView.reloadData()
                } else {
                    collectionView.performBatchUpdates({ () -> Void in
                        if let removed = collectionChanges.removedIndexes , removed.count > 0 {
                            collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                        }
                        if let inserted = collectionChanges.insertedIndexes , inserted.count > 0 {
                            collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                        }
                        if let changed = collectionChanges.changedIndexes , changed.count > 0 {
                            collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                        }
                        collectionChanges.enumerateMoves { fromIndex, toIndex in
                            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                    to: IndexPath(item: toIndex, section: 0))
                        }
                    }, completion: nil)
                }
                self.resetCacheAssets()
            }
        }
    }

// MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult != nil ? self.fetchResult!.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QPPhotoCell
        
        if let asset = self.fetchResult![indexPath.row] as? PHAsset {
            
            cell.updateSelected(select: nav?.AssetArr.index(of: asset) != nil)
            cell.model = asset
            cell.delegate = self
            cell.controller = self
            cell.nav = nav
            cell.representedAssetIdentifier = asset.localIdentifier
            setAssetGridThumbnailSize()
            self.imageManager.requestImage(for: asset, targetSize: self.assetGridThumbnailSize!, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.photoImageView.image = image
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //查看大图页
        let previewController = QPPhotoPreviewViewController()
        previewController.allSelectImage = self.fetchResult as! PHFetchResult<AnyObject>?
        previewController.currentPage = indexPath.row
        previewController.fromDelegate = self
        self.navigationController?.show(previewController, sender: nil)
    }
    
    //cell的代理方法
    func eventSelectNumberChange(number: Int) {
        if let toolbar = self.toolbar {
            toolbar.changeNumber(number: number)
        }
    }
    
//MARK: - CollectionView的Layout
    class func configCustomCollectionLayout() -> UICollectionViewFlowLayout {
        let collectionLayout = UICollectionViewFlowLayout()
        
        let width = UIScreen.main.bounds.width - PhotoPickerConfig.MinimumInteritemSpacing * 2
        collectionLayout.minimumInteritemSpacing = PhotoPickerConfig.MinimumInteritemSpacing
        
        let cellToUsableWidth = width - (PhotoPickerConfig.ColNumber - 1) * PhotoPickerConfig.MinimumInteritemSpacing
        let size = cellToUsableWidth / PhotoPickerConfig.ColNumber
        collectionLayout.itemSize = CGSize(width:size, height: size)
        collectionLayout.minimumLineSpacing = PhotoPickerConfig.MinimumInteritemSpacing
        return collectionLayout
    }
}
//MARK: - 底部工具条的代理方法，确认
extension QPPhotoCollectionViewController: AlbumToolbarViewDelegate{
    func onFinishedButtonClicked(){
        if let nav = self.navigationController as? QPPhotoPickerViewController {
            nav.imageSelectFinish()
        }
    }
    //cell的代理方法
    func onPreviewPageBack() {
        self.collectionView?.reloadData()
        self.eventSelectNumberChange(number: (self.nav?.AssetArr.count)!)
    }
    
}
