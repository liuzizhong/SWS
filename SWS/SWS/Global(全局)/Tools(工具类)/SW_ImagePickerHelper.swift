//
//  SW_ImagePickerHelper.swift
//  SWS
//
//  Created by jayway on 2018/5/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_ImagePickerHelper: NSObject {
    
    static let shared = SW_ImagePickerHelper()
    
    private override init() {
        super.init()
    }
    
    func showPicturePicker(_ handleBlock: @escaping ((UIImage)->Void), cropMode: DZNPhotoEditorViewControllerCropMode = .square) {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let vc = getTopVC()
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let option = UIAlertAction(title: NSLocalizedString("拍摄", comment: ""), style: .default, handler: { [weak self] _ in
                self?.cameraAction(handleBlock, cropMode: cropMode)
            })
            actionSheet.addAction(option)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let option = UIAlertAction(title: NSLocalizedString("从手机相册选择", comment: ""), style: .default, handler: { [weak self] _ in
                self?.pictureAction(handleBlock, cropMode: cropMode)
            })
            actionSheet.addAction(option)
        }
        let cancelOption = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler:nil)
        actionSheet.addAction(cancelOption)
        vc.present(actionSheet, animated: true)
    }

    func pictureAction(_ handleBlock: @escaping ((UIImage)->Void), cropMode: DZNPhotoEditorViewControllerCropMode = .square) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    dispatch_async_main_safe {
                        self.presentToMediasPickerController(handleBlock, cropMode: cropMode)
                    }
                }
            })
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            presentToMediasPickerController(handleBlock, cropMode: cropMode)
        } else {
//            PrintLog("请前往系统设置中开启相册权限")
            showAlertMessage("请前往系统设置中开启相册权限", MYWINDOW)
            //            SystemAuthorizationService.showAuthorizationAlertWithType(.photos, selectIndexBlock: nil)
        }
    }

    func presentToMediasPickerController(_ handleBlock: @escaping ((UIImage)->Void), cropMode: DZNPhotoEditorViewControllerCropMode = .square) {
        let pickerImage = UIImagePickerController()
        pickerImage.sourceType = .photoLibrary
        pickerImage.allowsEditing = true
        pickerImage.cropMode = cropMode
        pickerImage.finalizationBlock = {  (picker, info) -> Void in
            self.handleImagePicker(picker!, info: info!, handleBlock: handleBlock, cropMode: cropMode)
        }
        pickerImage.cancellationBlock = {(picker) -> Void in
            self.dismiss(picker!)
        }
        let vc = getTopVC()
        if isIPad {
            pickerImage.modalPresentationStyle = .popover
            pickerImage.popoverPresentationController?.sourceView = vc.view
            pickerImage.popoverPresentationController?.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            pickerImage.popoverPresentationController?.permittedArrowDirections = []
        }
        pickerImage.navigationBar.isTranslucent = false
        vc.present(pickerImage, animated: true, completion: nil)
    }

    func cameraAction(_ handleBlock: @escaping ((UIImage)->Void), cropMode: DZNPhotoEditorViewControllerCropMode = .square) {
        let picker = UIImagePickerController()
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if (authStatus == AVAuthorizationStatus.notDetermined) {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) -> Void in
                DispatchQueue.main.async(execute: {
                    if(granted){
                        picker.sourceType = .camera
                        picker.allowsEditing = true
                        picker.cropMode = cropMode
                        picker.finalizationBlock = {  (picker, info) -> Void in
                            self.handleImagePicker(picker!, info: info!, handleBlock: handleBlock, cropMode: cropMode)
                        }
                        picker.cancellationBlock = {[weak self](picker) -> Void in
                            self?.dismiss(picker!)
                        }
//                        picker.navigationBar.isTranslucent = false
                        self.getTopVC().present(picker, animated: true, completion: nil)
                    }
                })
            })
        } else if (authStatus == AVAuthorizationStatus.authorized) {
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.cropMode = cropMode
            picker.finalizationBlock = {  (picker, info) -> Void in
                self.handleImagePicker(picker!, info: info!, handleBlock: handleBlock, cropMode: cropMode)
            }
            picker.cancellationBlock = {(picker) -> Void in
                self.dismiss(picker!)
            }
            getTopVC().present(picker, animated: true, completion: nil)
        } else {
            //            SystemAuthorizationService.showAuthorizationAlertWithType(.camera, selectIndexBlock: nil)
            showAlertMessage("请前往系统设置中开启拍摄权限", MYWINDOW)
        }
    }


    func handleImagePicker(_ picker: UIImagePickerController, info: [String: Any], handleBlock: @escaping ((UIImage)->Void), cropMode: DZNPhotoEditorViewControllerCropMode = .square) {
        dismiss(picker)
        
        let type = info[UIImagePickerController.InfoKey.mediaType.rawValue] as! String
        if type == "public.image" {
            let imageKey = cropMode == .none ? UIImagePickerController.InfoKey.originalImage.rawValue :         UIImagePickerController.InfoKey.editedImage.rawValue
            let image = info[imageKey] as! UIImage
//            dispatch_async_main_safe {
                handleBlock(image)
//            }
        } else {
            showAlertMessage("请选择图片格式文件", MYWINDOW)
        }
    }


    func dismiss(_ picker: UIImagePickerController) {
        if UIViewController.instancesRespond(to: #selector(getter: UIViewController.presentingViewController)) {
            picker.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            picker.parent?.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
