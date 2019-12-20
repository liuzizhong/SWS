//
//  SW_SummaryHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/5/2.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

typealias SelectImageBlock = (String)->Void

class SW_SummaryHeaderView: UIView {

    @IBOutlet weak var coverImgView: UIImageView!
    
    @IBOutlet weak var addImageBtn: QMUIButton!
    
    @IBOutlet weak var imageBgView: UIView!
    
    var selectImageBlock: SelectImageBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    fileprivate func setUp() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage(_:)))
        imageBgView.addGestureRecognizer(tap)
        addImageBtn.imagePosition = .top
        layoutIfNeeded()
        addImageBtn.addDottedLine()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
    
    @objc func tapImage(_ tap: UITapGestureRecognizer) {
        self.endEditing(true)
        addImageBtnClick(addImageBtn)
    }
    
    @IBAction func addImageBtnClick(_ sender: QMUIButton) {
        SW_ImagePickerHelper.shared.showPicturePicker({ (image) in
            self.coverImgView.image = image
            self.coverImgView.isHidden = false
            self.addImageBtn.isHidden = true
            if let data = image.compreseImage() {
                self.selectImageBlock?(data.base64EncodedString())
            }
        }, cropMode: .none)
    }
    
    
    deinit {
        PrintLog("deinit")
    }

}

