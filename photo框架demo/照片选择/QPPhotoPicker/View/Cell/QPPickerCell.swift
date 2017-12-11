//
//  QPPickerCell.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/10.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit

class QPPickerCell: UICollectionViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setCell(_ model: QPPhotoImageModel?) -> Void {
        if model == nil {
            photoImage.image = UIImage.init(named: "image_add")
        }else{
            photoImage.image = model?.smallImage
        }
    }
}
