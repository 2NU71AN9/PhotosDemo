//
//  QPPhotoCell.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos
protocol PhotoCollectionViewCellDelegate: class {
    func eventSelectNumberChange(number: Int);
    
}
class QPPhotoCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    //代理，实现方法在相册collectionView控制器中
    var delegate: PhotoCollectionViewCellDelegate?
    //cell所在的控制器
    var controller: UIViewController?
    //当前导航
    var nav: QPPhotoPickerViewController?
    //当前cell的PHAsset对象
    var model : PHAsset?
    //相册id
    var representedAssetIdentifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    func setUI(){
        self.photoImageView.contentMode = .scaleAspectFill
        self.photoImageView.clipsToBounds = true
        selectButton.setImage(UIImage.init(named: "picture_unselect"), for: .normal)
        selectButton.setImage(UIImage.init(named: "picture_select"), for: .selected)
    }
    //判断是否选中，更改UI
    func updateSelected(select:Bool){
        if select {
            selectButton.isSelected = true
        } else {
            selectButton.isSelected = false
        }
    }
    //点击button
    @IBAction func btnClicked(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            sender.isSelected = false
            if controller != nil {
                if nav == nil {
                    nav = controller?.navigationController as? QPPhotoPickerViewController
                }
                let index = nav?.AssetArr.index(of: self.model!)
                nav?.AssetArr.remove(at: index!)
                if self.delegate != nil {
                    self.delegate!.eventSelectNumberChange(number: (nav?.AssetArr.count)!)
                }
            }
        } else {
            if controller != nil {
                if (nav?.AssetArr.count)! >= (nav?.imageMaxSelectedNum)! - (nav?.alreadySelectedImageNum)! {
                    self.showSelectErrorDialog()
                    sender.isEnabled = !sender.isEnabled
                    return
                } else {
                    nav?.AssetArr.append(self.model!)
                    if self.delegate != nil {
                        self.delegate!.eventSelectNumberChange(number: (nav?.AssetArr.count)!)
                    }
                }
            }
        }
    }
    private func showSelectErrorDialog() {
        if self.controller != nil {
            let less = (nav?.imageMaxSelectedNum)! - (nav?.alreadySelectedImageNum)!
            
            let range = PhotoPickerConfig.ErrorImageMaxSelect.range(of:"#")
            var error = PhotoPickerConfig.ErrorImageMaxSelect
            error.replaceSubrange(range!, with: String(less))
            
            let alert = UIAlertController.init(title: nil, message: error, preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: PhotoPickerConfig.ButtonConfirmTitle, style: .default, handler: nil)
            alert.addAction(confirmAction)
            self.controller?.present(alert, animated: true, completion: nil)
        }
    }
    
}
