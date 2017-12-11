//
//  QPPhotoPicker.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.

import UIKit
import Photos


private let reuseIdentifier = "QPPickerCell"

class QPPhotoPickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, PhotoPickerControllerDelegate, QPSinglePhotoPreviewViewDeleagte {
    
    var QPPhotos = [QPPhotoImageModel]()
    var controller: UIViewController?
    var collectionView: UICollectionView?
    var imagePickerController:UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        // 设置是否可以管理已经存在的图片或者视频
        imagePickerController.allowsEditing = true
        return imagePickerController
    }()
    var maxNum = 9
    
    init(controller: UIViewController, frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.controller = controller
        createCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //设置collectionView
    func createCollectionView(){
        controller?.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: PhotoPickerConfig.selectWidth,height: PhotoPickerConfig.selectWidth)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: self.frame.size), collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsetsMake(
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing,
            PhotoPickerConfig.MinimumInteritemSpacing
        )
        self.addSubview(collectionView!)
    }
    

// MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if QPPhotos.count == maxNum {
            return QPPhotos.count
        }
        return QPPhotos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QPPickerCell
        var model: QPPhotoImageModel?
        if indexPath.row == QPPhotos.count {
            model = nil
        }else{
            model = QPPhotos[indexPath.row]
        }
        cell.setCell(model)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == QPPhotos.count {
            addPhoto(indexPath)
        }else{
            eventPreview(index: indexPath.row)
        }
    }
    
    func addPhoto(_ indexPath: IndexPath){
        let ac = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "拍照", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.getImageFromPhotoLib(type: .camera)
        }
        let action2 = UIAlertAction.init(title: "从手机相册选择", style: .default) { (action) in
            //添加照片
            self.addPhotos()

        }
        let action = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        ac.addAction(action1)
        ac.addAction(action2)
        ac.addAction(action)
        controller?.present(ac, animated: true, completion: nil)
    }
    func initImagePickerController() {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        // 设置是否可以管理已经存在的图片或者视频
        self.imagePickerController.allowsEditing = true
    }
    
    func getImageFromPhotoLib(type:UIImagePickerControllerSourceType){
        self.imagePickerController.sourceType = type
        //判断是否支持相册
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller?.present(self.imagePickerController, animated: true, completion:nil)
        }
    }
    
    
    func addPhotos(){
        //初始化并弹出相册页
        let vc = QPPhotoPickerViewController(type: PageType.AllAlbum)
        vc.imageSelectDelegate = self
        //最大照片数量
        vc.imageMaxSelectedNum = maxNum
        vc.alreadySelectedImageNum = QPPhotos.count
        controller?.present(vc, animated: true, completion: nil)
    }
    //添加照片的协议方法
    func onImageSelectFinished(images: [PHAsset]) {
        QPPhotoDataAndImage.getImagesAndDatas(photos: images) { (array) in
            for model in array!{
                self.QPPhotos.append(model)
            }
            self.collectionView?.reloadData()
        }
    }
    
    
    //查看大图
    func eventPreview(index: Int){
        let preview = QPSinglePhotoPreviewViewController()
        let nav = UINavigationController.init(rootViewController: preview)
        let data = self.getModelExcept()
        preview.selectImages = data
        preview.delegate = self
        preview.currentPage = index
        

        let animation = CATransition.init()
        animation.duration = 0.5
        animation.subtype = kCATransitionFromRight
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
        
        
        controller?.present(nav, animated: false, completion: nil)
    }
    
    //查看大图后的协议方法
    func removeElement(element: QPPhotoImageModel?) {
        if let current = element {
            self.QPPhotos = self.QPPhotos.filter({$0 != current})
        }
        collectionView?.reloadData()
    }
    
    private func getModelExcept()->[QPPhotoImageModel]{
        var newModels = [QPPhotoImageModel]()
        for i in 0..<self.QPPhotos.count {
            let item = self.QPPhotos[i]
            newModels.append(item)
        }
        return newModels
    }
}

extension QPPhotoPickerView: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type:String = (info[UIImagePickerControllerMediaType]as!String)
        if type == "public.image" {
            let bigimg = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imgData = UIImageJPEGRepresentation(bigimg!, 0.5)
            let smallImage = info[UIImagePickerControllerEditedImage] as? UIImage
            let model = QPPhotoImageModel()
            model.bigImage = bigimg
            model.imageData = imgData
            model.smallImage = smallImage
            self.QPPhotos.append(model)
            self.collectionView?.reloadData()
            picker.dismiss(animated: true, completion: { 
                self.imagePickerController.delegate = nil
            })
        }
    }
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }
    
}
