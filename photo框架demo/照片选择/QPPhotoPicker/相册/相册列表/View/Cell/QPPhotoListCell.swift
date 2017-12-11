//
//  QPPhotoListCell.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/5.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit
import Photos

class QPPhotoListCell: UITableViewCell {

    @IBOutlet weak var CoverImage: UIImageView!
    @IBOutlet weak var PhotoTitle: UILabel!
    @IBOutlet weak var PhotoNum: UILabel!
    let imageSize: CGFloat = 80
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero
        let bgView = UIView()
        bgView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.selectedBackgroundView = bgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func renderData(result:PHFetchResult<AnyObject>, label: String?){
        self.PhotoTitle.text = label
        self.PhotoNum.text = String(result.count)
        if result.count > 0 {
            if let firstImageAsset = result[0] as? PHAsset {
                let retinaMultiplier = UIScreen.main.scale
                let realSize = self.imageSize * retinaMultiplier
                let size = CGSize(width:realSize, height: realSize)
                
                let imageOptions = PHImageRequestOptions()
                imageOptions.resizeMode = .exact
                
                PHImageManager.default().requestImage(for: firstImageAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, info) -> Void in
                    self.CoverImage.image = image
                })
            }
        }
    }
}
