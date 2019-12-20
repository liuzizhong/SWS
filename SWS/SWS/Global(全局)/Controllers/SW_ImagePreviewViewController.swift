//
//  SW_ImagePreviewViewController.swift
//  SWS
//
//  Created by jayway on 2018/11/29.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_ImagePreviewViewController: QMUIImagePreviewViewController {
    /// 现在大多是这种情况
    private var images = [UIImage]()
    
    private var imageUrls = [String]()
    
    @objc init(_ images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
        presentingStyle = .zoom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreviewView.delegate = self
        imagePreviewView.currentImageIndex = 0
        
//        customgw
        // Do any additional setup after loading the view.
    }
    
    deinit {
        PrintLog("deinit")
    }
   
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension SW_ImagePreviewViewController: QMUIImagePreviewViewDelegate {
    func numberOfImages(in imagePreviewView: QMUIImagePreviewView!) -> UInt {
        return UInt(images.count)
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView!, renderZoomImageView zoomImageView: QMUIZoomImageView!, at index: UInt) {
        zoomImageView.image = images[Int(index)]
    }
    
    func imagePreviewView(_ imagePreviewView: QMUIImagePreviewView!, assetTypeAt index: UInt) -> QMUIImagePreviewMediaType {
        return .image
    }
    
    func singleTouch(inZooming zoomImageView: QMUIZoomImageView!, location: CGPoint) {
        dismiss(animated: true, completion: nil)
    }
    
    func longPress(inZooming zoomImageView: QMUIZoomImageView!) {
        
        let actionsheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if let popoverController = actionsheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        actionsheet.addAction(UIAlertAction(title: "保存相片", style: .default, handler: { (action) in
            if QMUIAssetsManager.authorizationStatus() == .notDetermined {
                QMUIAssetsManager.requestAuthorization { (status) in
                    dispatch_async_main_safe {
                        if status == .authorized {
                            self.saveImageToAlbum(image: zoomImageView.image)
                        } else {
                            showAlertMessage("请在设备的\"设置-隐私-照片\"选项中，允许效率+访问你的手机相册", MYWINDOW)
                        }
                    }
                }
            } else if QMUIAssetsManager.authorizationStatus() == .notAuthorized {
                showAlertMessage("请在设备的\"设置-隐私-照片\"选项中，允许效率+访问你的手机相册", MYWINDOW)
            } else {
                self.saveImageToAlbum(image: zoomImageView.image)
            }
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler:nil))
        present(actionsheet, animated: true, completion: nil)
    }
    
    private func saveImageToAlbum(image: UIImage) {
        /// 标识找到的第一个相册
        var isFirst = true
        QMUIAssetsManager.sharedInstance()?.enumerateAllAlbums(with: .all, showEmptyAlbum: true, showSmartAlbumIfSupported: false, using: { (resultAssetsGroup) in
            if isFirst {
                QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(image, resultAssetsGroup, { (asset, error) in
                    if error == nil {
                        QMUITips.showSucceed("保存成功", in: self.view, hideAfterDelay: 2)
                    } else {
                        QMUITips.showError("保存失败", in: self.view, hideAfterDelay: 2)
                    }
                })
                isFirst = false
            }
        })
    }
}
