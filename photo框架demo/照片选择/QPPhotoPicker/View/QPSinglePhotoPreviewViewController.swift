//
//  QPSinglePhotoPreviewViewController.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/10.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos
protocol QPSinglePhotoPreviewViewDeleagte {
    func removeElement(element: QPPhotoImageModel?)
}

class QPSinglePhotoPreviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoPreviewCellDelegate {
    
    var selectImages = [QPPhotoImageModel]()
    private var collectionView: UICollectionView?
    private let cellIdentifier = "QPPhotoPreviewCell"
    var currentPage: Int = 0
    var delegate: QPSinglePhotoPreviewViewDeleagte?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "back", style: .plain, target: self, action: nil)
        self.configNavigationBar()
        self.configCollectionView()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * self.view.bounds.width, y: 0), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configNavigationBar(){
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "navi_back"), style: .plain, target: self, action: #selector(self.dissmiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.eventRemoveImage))
    }
    func dissmiss(){
        let animation = CATransition.init()
        animation.duration = 0.2
        animation.subtype = kCATransitionFromRight
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    func eventRemoveImage(){
        
        let element = self.selectImages.remove(at: self.currentPage)
        self.updatePageTitle()
        let indePath = IndexPath.init(row: currentPage, section: 0)
        self.collectionView?.deselectItem(at: indePath, animated: true)
        self.delegate?.removeElement(element: element)
        
        if (self.selectImages.count) > 0{
            self.collectionView?.reloadData()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
        if selectImages.count == 0 {
            dissmiss()
        }
    }
    
    func configCollectionView(){
        self.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:self.view.frame.width,height: self.view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView!.dataSource = self
        self.collectionView!.delegate = self
        self.collectionView!.isPagingEnabled = true
        self.collectionView!.scrollsToTop = false
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.contentOffset = CGPoint(x:0, y: 0)
        self.collectionView!.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.selectImages.count), height: self.view.bounds.height)
        
        self.view.addSubview(self.collectionView!)
        self.collectionView!.register(QPPhotoPreviewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
    }
    
    private func updatePageTitle(){
        self.title =  String(self.currentPage+1) + "/" + String(self.selectImages.count)
    }
    
    //PhotoPreviewCellDelegate的协议方法
    func onImageSingleTap() {
        let status = !UIApplication.shared.isStatusBarHidden
        UIApplication.shared.setStatusBarHidden(status, with: .slide)
        self.navigationController?.setNavigationBarHidden(status, animated: true)
    }
// MARK: -  scroll page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.currentPage = Int(offset.x / self.view.bounds.width)
        self.updatePageTitle()
    }

//MARK: - CollectionView的协议方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectImages.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! QPPhotoPreviewCell
        cell.delegate = self
        let image = self.selectImages[indexPath.row].bigImage
        if let asset = self.selectImages[indexPath.row].asset {
            cell.renderModel(asset: asset, bigImage: image)
        }else{
            cell.renderModel(asset: nil, bigImage: image)
        }
        
        return cell
    }
}
