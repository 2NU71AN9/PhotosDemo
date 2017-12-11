//
//  PhotoPreviewBottomBarView.swift
//  QPPhotoPickerDemo
//
//  Created by chudian on 2017/4/6.
//  Copyright © 2017年 qp. All rights reserved.
//

import UIKit

protocol PhotoPreviewBottomBarViewDelegate:class{
    func onDoneButtonClicked()
}

class PhotoPreviewBottomBarView: UIView {
    
    var doneNumberAnimationLayer: UIView?
    var labelTextView: UILabel?
    var buttonDone: UIButton?
    var doneNumberContainer: UIView?
    
    weak var delegate: PhotoPreviewBottomBarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configView()
    }
    
    private func configView(){
        self.backgroundColor = PhotoPickerConfig.PreviewBarBackgroundColor
        
        // button
        self.buttonDone = UIButton(type: .custom)
        
        let toolbarHeight = bounds.height
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        let padding:CGFloat = 5
        let width = self.bounds.width
        
        buttonDone!.frame = CGRect(x: width - buttonWidth - padding, y: (toolbarHeight - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)
        buttonDone!.setTitle(PhotoPickerConfig.ButtonDone, for: .normal)
        buttonDone!.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        buttonDone!.setTitleColor(PhotoPickerConfig.GreenTinColor, for: .normal)
        buttonDone!.addTarget(self, action: #selector(PhotoPreviewBottomBarView.eventDoneClicked), for: .touchUpInside)
        buttonDone!.isEnabled = true
        buttonDone!.setTitleColor(UIColor.black, for: .disabled)
        self.addSubview(self.buttonDone!)
        
        // done number
        let labelWidth:CGFloat = 20
        let labelX = buttonDone!.frame.minX - labelWidth
        let labelY = (toolbarHeight - labelWidth) / 2
        
        self.doneNumberContainer = UIView(frame: CGRect(x:labelX, y:labelY, width: labelWidth, height:labelWidth))
        let labelRect = CGRect(x:0, y:0, width: labelWidth, height: labelWidth)
        self.doneNumberAnimationLayer = UIView.init(frame: labelRect)
        self.doneNumberAnimationLayer!.backgroundColor = PhotoPickerConfig.GreenTinColor
        self.doneNumberAnimationLayer!.layer.cornerRadius = labelWidth / 2
        doneNumberContainer!.addSubview(self.doneNumberAnimationLayer!)
        
        self.labelTextView = UILabel(frame: labelRect)
        self.labelTextView!.textAlignment = .center
        self.labelTextView!.backgroundColor = UIColor.clear
        self.labelTextView!.textColor = UIColor.white
        doneNumberContainer!.addSubview(self.labelTextView!)
        
        self.addSubview(self.doneNumberContainer!)
    }
    
    // MARK: -  Event delegate
    func eventDoneClicked(){
        if let delegate = self.delegate{
            delegate.onDoneButtonClicked()
        }
    }
    
    func changeNumber(number:Int,animation:Bool){
        self.labelTextView?.text = String(number)
        if number > 0 {
            self.buttonDone?.isEnabled = true
            self.doneNumberContainer?.isHidden = false
            if animation {
                self.doneNumberAnimationLayer!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.doneNumberAnimationLayer!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            }
            
        } else {
            self.buttonDone?.isEnabled  = false
            self.doneNumberContainer?.isHidden = true
        }
    }
    
}
