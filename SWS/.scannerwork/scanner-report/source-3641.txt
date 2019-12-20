//
//  SW_TryDriveUpImageViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_TryDriveUpImageViewController: UIViewController {

    @IBOutlet weak var imageContentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var reTakeButton: UIButton!
    
    @IBOutlet weak var upLoadButton: SW_BlueButton!
    
    var record: SW_AccessCustomerRecordModel!
    
    var customerId = ""
    
    var testDriveRecordId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        record = SW_AccessCustomerRecordModel()
        record.accessType = .tryDrive
        record.customerId = customerId
        record.testDriveRecordId = testDriveRecordId
        setup()
        showTipAlert()
        dispatch_delay(0.1) {
            self.imageContentView.addRoundedDottedBorder([3,3], cornerRadius: 2)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        reTakeButton.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        reTakeButton.layer.cornerRadius = 3
        reTakeButton.layer.borderColor = UIColor.mainColor.blue.cgColor
        reTakeButton.layer.borderWidth = 1
    }
//    请将试驾协议和驾驶证摆放在正确的位置使试驾协议的边缘在蓝框内并尽量对齐确保图像清晰
    private func showTipAlert() {
        alertControllerShow(title: "请将驾驶证摆放在试驾协议空白处，并拍清晰的照片上传。", message: nil, rightTitle: "拍 照", rightBlock: { (_, _) in
            SW_ImagePickerHelper.shared.cameraAction({ (img) in
                self.handleImage(img)
            }, cropMode: .none)
        }, leftTitle: "取 消", leftBlock: { (_, _) in
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    private func handleImage(_ selectImage: UIImage) {
        imageView.image = selectImage
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    @IBAction func reTakeAction(_ sender: UIButton) {
        SW_ImagePickerHelper.shared.cameraAction({ (img) in
            self.handleImage(img)
        }, cropMode: .none)
    }
    
    @IBAction func upLoadAction(_ sender: UIButton) {
        if let image = imageView.image {
            
            MBProgressHUD.hide()
            let hud = MBProgressHUD.showAdded(to: MYWINDOW, animated: true)
            hud?.mode = MBProgressHUDModeAnnularDeterminate
            hud?.animationType = MBProgressHUDAnimationFade
            hud?.labelText = "正在上传"
            
            SWSUploadManager.share.upLoadTestDriveImage(image, block: { (success, key, prefix) in
                hud?.hide(true)
                if let key = key, success {
                    //上传成功
                    self.record.testDriveContractImg = key
                    self.navigationController?.pushViewController(SW_StartTryDriveViewController(self.record), animated: true)
                }
            }) { (key, progress) in
                hud?.progress = progress
            }
            
        }
    }
    
}
