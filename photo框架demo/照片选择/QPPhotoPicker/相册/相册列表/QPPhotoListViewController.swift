//
//  QPPhotoListViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

private let albumTableViewCellItentifier = "QPPhotoListCell"
class QPPhotoListViewController: UITableViewController, PHPhotoLibraryChangeObserver {
    
    
    var albums = [QPPhotoModel]()
    // 自定义需要加载的相册
    var customSmartCollections = [
        PHAssetCollectionSubtype.smartAlbumUserLibrary, // All Photos
        PHAssetCollectionSubtype.smartAlbumRecentlyAdded // Rencent Added
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //iOS9.0以上添加截屏图片
        if #available(iOS 9.0, *) {
            customSmartCollections.append(.smartAlbumScreenshots)
        }
        // 注册通知 你可以在你的app中时刻监听照片库的状态
        PHPhotoLibrary.shared().register(self)
        setupTableView()
        configNavigationBar()
        loadAlbums(false)
    }
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    //设置TableView
    private func setupTableView(){
        self.tableView.register(UINib.init(nibName: albumTableViewCellItentifier, bundle: nil), forCellReuseIdentifier: albumTableViewCellItentifier)
        
        // 自定义 separatorLine样式
        self.tableView.rowHeight = PhotoPickerConfig.AlbumTableViewCellHeight
        self.tableView.separatorColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.15)
        self.tableView.separatorInset = UIEdgeInsets.zero
        // 去除tableView多余空格线
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    //将数据进行赋值
    private func loadAlbums(_ replace: Bool){
        if replace {
            self.albums.removeAll()
        }
        
        // 加载相册的所有小图
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        for i in 0 ..< smartAlbums.count  {
            if customSmartCollections.contains(smartAlbums[i].assetCollectionSubtype){
                self.filterFetchResult(collection: smartAlbums[i])
            }
        }
        
        // 用户相册
        let topUserLibarayList = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< topUserLibarayList.count {
            if let topUserAlbumItem = topUserLibarayList[i] as? PHAssetCollection {
                self.filterFetchResult(collection: topUserAlbumItem)
            }
        }
        //获取完数据后刷新
        self.tableView.reloadData()
    }
    
    private func filterFetchResult(collection: PHAssetCollection){
        //将照片进行时间排序
        let Instance = QPPhotoFetchOptions.init()
        let fetchResult = PHAsset.fetchAssets(in: collection, options: Instance)
        //创建模型并加入数组
        if fetchResult.count > 0 {
            let model = QPPhotoModel(result: fetchResult as! PHFetchResult<AnyObject> as! PHFetchResult<PHObject>, label: collection.localizedTitle, assetType: collection.assetCollectionSubtype)
            self.albums.append(model)
        }
    }
    //设置导航，返回按钮
    private func configNavigationBar(){
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.eventViewControllerDismiss))
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    func eventViewControllerDismiss(){
        let nav = self.navigationController as! QPPhotoPickerViewController
        nav.AssetArr.removeAll()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

    
//MARK: - PHPhotoLibraryChangeObserver的协议方法----相册中数据改变后，重新获取数据，然后刷新
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.loadAlbums(true)
    }
//TableView的协议方法
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumTableViewCellItentifier, for: indexPath) as! QPPhotoListCell
        let model = self.albums[indexPath.row]
        cell.renderData(result: model.fetchResult as! PHFetchResult<AnyObject>, label: model.name)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //跳转至照片页
        showDetailPageModel(model: albums[indexPath.row])
    }
    private func showDetailPageModel(model: QPPhotoModel){
        let layout = QPPhotoCollectionViewController.configCustomCollectionLayout()
        let controller = QPPhotoCollectionViewController(collectionViewLayout: layout)
        controller.fetchResult = model.fetchResult
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
