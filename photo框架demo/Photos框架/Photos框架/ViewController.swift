//
//  ViewController.swift
//  Photos框架
//
//  Created by X.T.X on 2017/11/1.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        SLPhotosManager.choicePhotoFromAlbum(self, count: 1) { (photos) in
            print(photos)
            self.imageView.image = photos.first
        }
    }

}
