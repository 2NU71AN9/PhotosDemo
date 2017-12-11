//
//  SLPhotoViewController.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/15.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import Photos

class SLPhotoViewController: SLPhotoBaseViewController {

    let itemCount: CGFloat = UIScreen.main.bounds.width > 375 ? 5 : 4
    
    var assetCollection: PHAssetCollection? {
        didSet {
            guard assetCollection != nil else {
                print("assetCollection == nil")
                return
            }
            
            title = assetCollection!.localizedTitle?.chinese()
            
            DispatchQueue.global().async {
                
                let fetchResult = PHAsset.fetchAssets(in: self.assetCollection!, options: nil)
                fetchResult.enumerateObjects { (asset, index, stop) in
                    let model = PhotoModel()
                    model.asset = asset
                    self.photos.append(model)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    if self.photos.count > 0 {
                        self.collectionView.scrollToItem(at: IndexPath(item: self.photos.count - 1, section: 0), at: .bottom, animated: false)
                    } else {
                        self.authorLable.text = "没有任何照片哦!"
                        self.view.addSubview(self.authorLable)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        addCollection()
        
        showCancleBtn()
    }
    
    fileprivate func addCollection() {
        collectionView.register(SLPhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        view.addSubview(collectionView)
        
        buttomView.delegate = self
        view.addSubview(buttomView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 44)
        buttomView.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionview.backgroundColor = UIColor.white
        collectionview.delegate = self
        collectionview.dataSource = self
        return collectionview
    }()

    fileprivate var photos: [PhotoModel] = [PhotoModel]()
    fileprivate var selectPhotos: [PhotoModel] = [PhotoModel]()

    fileprivate var buttomView: SLButtomView = {
        let buttonView = SLButtomView(frame: .zero)
        buttonView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return buttonView
    }()
}

extension SLPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SLButtomViewDelegate, SLPhotoCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SLPhotoCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.model = self.photos[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = self.photos[indexPath.item]
        
        if selectPhotos.count > 0 && model.asset?.mediaType == .video {
            let alterVc = UIAlertController(title: nil, message: "已选有图片，不能选择视频", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "确定", style: .cancel) { (action) in
                print(action.title ?? "标题")
            }
            alterVc.addAction(cancleAction)
            self.present(alterVc, animated: true, completion: nil)
            
            return
        }
        
//        let previewVc = HBPreviewController(delegate: self.delegate!)
//        previewVc.previewDelegate = self
//        previewVc.selectItem(self.photos, indexPath: indexPath, choosePhotos: self.selectPhotos)
//        self.navigationController?.pushViewController(previewVc, animated: true)
        
    }
    //#MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW = (UIScreen.main.bounds.size.width - (itemCount + 1) * 2) / itemCount
        return CGSize(width: itemW, height: itemW)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 2, 2)
    }
    //MARK: HBCollectionViewCellDelegate
    func collectionViewChickStateBtn(_ cell: SLPhotoCell, model: PhotoModel, indexPath: IndexPath, chickBtn: UIButton) {
        
        if !model.isSelect && checkMaxCount(selectPhotos){ return }
        
        model.isSelect = !model.isSelect
        chickBtn.isSelected = model.isSelect
        
        if selectPhotos.contains(model) {
            selectPhotos.remove(at: selectPhotos.index(of: model)!)
        }else{
            //chickBtn.hb_starBoundsAnimation()
            selectPhotos.append(model)
        }
        if selectPhotos.count == 0 {
            buttomView.stopMidBtnAnimation()
        }else{
            buttomView.starMidBtnAnimation(String(selectPhotos.count))
        }
        
    }
    //MARK: HBButtomViewDelegate
    func buttomViewChick(_ btn: UIButton, state: buttonChick) {
        switch state {
        case .send:
            complete?(selectPhotos, true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - SLButtomViewDelegate
protocol SLButtomViewDelegate: NSObjectProtocol {
    func buttomViewChick(_ btn: UIButton, state: buttonChick)
}
//MARK: 底部工具栏
public enum buttonChick: Int {
    case send
}

class SLButtomView: UIView {
    
    weak var delegate: SLButtomViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.rightBtn)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rightBtn.frame = CGRect(x: bounds.width - 100, y: frame.height/2 - 15, width: 100, height: 30)
    }
    /**
     清空选中数字提示
     */
    func stopMidBtnAnimation() {
        self.rightBtn.isEnabled = false
        self.rightBtn.setTitle("确定", for: .normal)
    }
    
    /**
     开始选中数据提示
     - parameter title: 显示数字
     */
    func starMidBtnAnimation(_ title: String) {
        self.rightBtn.isEnabled = true
        self.rightBtn.setTitle("确定 (\(title))", for: .normal)
    }
    
    /**
     渐变动画
     - parameter isHide: 是否隐藏
     */
    func starAlphaAnimation(_ isHide: Bool) {
        if isHide {
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 0
            }, completion: { (Finished) in
                self.isHidden = isHide
            })
        } else {
            isHidden = isHide
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
            }, completion: { (Finished) in
            })
        }
    }
    
    @objc fileprivate func sendBtnChick(_ btn: UIButton) {
        self.delegate?.buttomViewChick(btn, state: .send)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var rightBtn: UIButton = {
        
        let btn = UIButton()
        btn.setTitleColor(UIColor(red: 0x00/255, green: 0xcd/255, blue: 0x00/255, alpha: 1), for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .disabled)
        btn.setTitle("确定", for: UIControlState())
        btn.addTarget(self, action: .buttomSendChick, for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
}

// MARK: - SLPhotoCellDelegate
protocol SLPhotoCellDelegate: NSObjectProtocol {
    func collectionViewChickStateBtn(_ cell: SLPhotoCell, model: PhotoModel, indexPath: IndexPath, chickBtn: UIButton)
}

// MARK: - SLPhotoCell
class SLPhotoCell: UICollectionViewCell {
    
    private var imageSize: CGSize?
    
    weak var delegate: SLPhotoCellDelegate?
    
    var indexPath: IndexPath?
    
    weak var model: PhotoModel? {
        didSet {
            guard model != nil else {
                return
            }
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = .fast
            
            /// 有缓存
            PHCachingImageManager.default().requestImage(for: model!.asset!, targetSize:imageSize! , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
                self.imageView.image = image
            })
            /// 无缓存
//            PHImageManager.default().requestImage(for: model!.asset!, targetSize:imageSize! , contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, imageDic) in
//                self.imageView.image = image
//            })
            self.chooseBtn.isSelected = (model?.isSelect)!
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        imageSize = self.contentView.bounds.size
        contentView.addSubview(self.imageView)
        contentView.addSubview(self.chooseBtn)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        chooseBtn.frame = CGRect(x: bounds.width - 30, y: 0, width: 30, height: 30)
    }
    
    @objc fileprivate func chickChooseBtn(_ getBtn: UIButton) -> Void {
        delegate?.collectionViewChickStateBtn(self, model: model!, indexPath: indexPath!, chickBtn: getBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var imageView: UIImageView = {
        let icon = UIImageView(frame: .zero)
        icon.layer.masksToBounds = true
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    fileprivate lazy var chooseBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "select_No"), for: .normal)
        btn.setImage(UIImage(named: "select_Yes"), for: .selected)
        btn.addTarget(self, action: .chooseBtnChick, for: .touchUpInside)
        btn.imageView?.contentMode = .center
        return btn
    }()
}

private extension Selector {
    static let chooseBtnChick = #selector(SLPhotoCell.chickChooseBtn(_:))
    static let buttomSendChick = #selector(SLButtomView.sendBtnChick(_:))
}
