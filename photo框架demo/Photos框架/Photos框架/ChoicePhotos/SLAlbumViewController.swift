//
//  SLAlbumViewController.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/15.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import Photos

class SLAlbumViewController: SLPhotoBaseViewController {
    
    /// 最大选中数量，默认9张
    var maxPhotos: Int = 9
    
    fileprivate lazy var tableView: UITableView = {
        let tabview = UITableView(frame: .zero, style: .plain)
        tabview.tableFooterView = UIView()
        tabview.delegate = self
        tabview.dataSource = self
        return tabview
    }()
    
    fileprivate var photoList: [SLAlbumModel]  = [SLAlbumModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片"
        showCancleBtn()
        
        tableView.register(SLAlbumCell.self, forCellReuseIdentifier: "albumCell")
        view.addSubview(tableView)
        
        loadAlbum()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }

    /// 获取相册
    func loadAlbum() {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) in
            if status == .notDetermined {
                print("NotDetermined")
            }else if status == .authorized {
                
                DispatchQueue.global().async{
                    
                    /// 相机胶卷
                    let cameraRoll: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                    cameraRoll.enumerateObjects{ (object, index, stop) in
                        let model = SLAlbumModel.init(object)
                        if model.collectionTitle == "相机胶卷" {
                            self.photoList.insert(model, at: 0)
                        }else{
                            self.photoList.append(model)
                        }
                    }
                    /// 其他相册
                    let newRoll: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                    newRoll.enumerateObjects{ (object, index, stop) in
                        let model = SLAlbumModel.init(object)
                        self.photoList.append(model)
                    }
                    
                    /// 刷新界面
                    DispatchQueue.main.async{
                        let model = self.photoList[0]
                        if model.collectionTitle == "相机胶卷" {
                            let collectionVc = SLPhotoViewController(complete: self.complete!)
                            collectionVc.assetCollection = model.assetCollection
                            self.navigationController?.pushViewController(collectionVc, animated: false)
                        }
                        self.tableView.reloadData()
                    }
                }
            }else if status == .restricted {
                print("Restricted")
            }else if status == .denied {
                print("没有获取到用户授权")
                DispatchQueue.main.async {
                    self.authorLable.text = "请在iPhone的\"设置-隐私-照片\"选项中，\n允许访问你的手机相册。"
                    self.view.addSubview(self.authorLable)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SLAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! SLAlbumCell
        cell.model = photoList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = photoList[indexPath.row]
        let collectionVc = SLPhotoViewController(complete: complete!)
        collectionVc.assetCollection = model.assetCollection
        navigationController?.pushViewController(collectionVc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

//MARK: 相册分类列表cell
class SLAlbumCell: UITableViewCell {
    
    var model: SLAlbumModel? {
        didSet {
            if let getModel = model {
                iconImageView.image = getModel.collectionLastImage
                title.text = getModel.collectionTitle
                subtitle.text = "\(getModel.collectionImageCount)" + "张照片"
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionStyle = .none
        
        iconImageView.frame.origin.x = 10
        iconImageView.frame.size = CGSize(width: 50, height: 50)
        iconImageView.center.y = contentView.center.y
        
        title.sizeToFit()
        title.frame.origin.x = iconImageView.frame.maxX + 15
        title.center.y = iconImageView.center.y
        
        subtitle.sizeToFit()
        subtitle.frame.origin.x = title.frame.maxX + 10
        subtitle.center.y = title.center.y
        
    }
    //FIXME: 修改frame
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(title)
        self.contentView.addSubview(subtitle)
    }
    
    //MARK: getter 设置cell子视图
    fileprivate lazy var iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.layer.masksToBounds = true
        return icon
    }()
    
    fileprivate lazy var title: UILabel = {
        let leftTitle = UILabel()
        return leftTitle
    }()
    
    fileprivate lazy var subtitle: UILabel = {
        let rightTitle = UILabel()
        return rightTitle
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

