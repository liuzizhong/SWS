//
//  SWSUploadManager.swift
//  SWS
//
//  Created by jayway on 2018/4/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Qiniu

class SWSUploadManager: NSObject {

    let uploadManager = QNUploadManager()
    
    static let share = SWSUploadManager()
    
    private override init() {
        super.init()
    }
    
    //MARK: - 上传头像
    /// 上传头像到七牛
    ///
    /// - Parameters:
    ///   - image: 上传的头像
    ///   - block: 回调是否成功，上传成功后的key
    func upLoadPortrait(_ image: UIImage, block: @escaping (_ success: Bool, _ key: String?)->Void) {
        getUptoken { (token, key) in
            if let data = image.compreseImage() {
                self.uploadManager?.put(data, key: key + ".jpg", token: token, complete: { (info, key, response) in
                    if info?.isOK == true {
                        PrintLog(key)
                        PrintLog(response)
                        block(true,key)
                    } else {
                        showAlertMessage(info?.error.localizedDescription ?? "网络异常", MYWINDOW)
                        block(false,nil)
                    }
                }, option: nil)
            } else {
                showAlertMessage("图片转换失败", MYWINDOW)
            }
        }
    }
    
    /// 获取上传头像token
    ///
    /// - Parameter block: 回调token  key
    func getUptoken(_ block: @escaping (_ token:String,_ key:String)->Void) {
        if let user = SW_UserCenter.shared.user {
            SWSQiniuService.getUpToken(user.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
//                    "token": "Fxe6dMk9hSlOd5N-dcpkfvuP1sQ-SfuixOPRS-1V:CCtCARK1MCdcDgl4Df0HX1p_hEo=:eyJzY29wZSI6InlyLW9hLXRlc3QiLCJkZWFkbGluZSI6MTUyMzkzNDczMH0=",
//                    "key": "portrait/2/1523931130871",
                    block(json["token"].stringValue, json["key"].stringValue)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        }
    }
    
    //MARK: - 上传工作报告头像
    /// 上传工作报告图片到七牛
    ///
    /// - Parameters:
    ///   - image: 上传的头像
    ///   - block: 回调是否成功，上传成功后的key
    func upLoadWorkReportImage(_ image: UIImage, block: @escaping (_ success: Bool, _ key: String?,_ prefix:String?)->Void, progressBlock: @escaping QNUpProgressHandler) {
        getWorkReportUpToken({ (token, key, prefix) in
            if let data = image.compreseImage() {
                self.uploadManager?.put(data, key: key + ".jpg", token: token, complete: { (info, key, response) in
                    if info?.isOK == true {
                        block(true,key, prefix)
                    } else {
                        showAlertMessage(info?.error.localizedDescription ?? "网络异常", MYWINDOW)
                        block(false,nil, nil)
                    }
                }, option: QNUploadOption(progressHandler: progressBlock))
            } else {
                block(false,nil, nil)
                showAlertMessage("图片转换失败", MYWINDOW)
            }
        }, failBlock: {
            block(false,nil, nil)
        })
    }
    
    
    /// 获取上传工作报告图片token
    ///
    /// - Parameter block: 回调token  key
    func getWorkReportUpToken(_ block: @escaping (_ token:String,_ key:String,_ prefix:String)->Void, failBlock: @escaping NormalBlock) {
        if let user = SW_UserCenter.shared.user {
            SWSQiniuService.getWorkReportUpToken(user.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    //                    "token": "Fxe6dMk9hSlOd5N-dcpkfvuP1sQ-SfuixOPRS-1V:CCtCARK1MCdcDgl4Df0HX1p_hEo=:eyJzY29wZSI6InlyLW9hLXRlc3QiLCJkZWFkbGluZSI6MTUyMzkzNDczMH0=",
                    //                    "key": "portrait/2/1523931130871",
                    block(json["token"].stringValue, json["key"].stringValue, json["imagePrefix"].stringValue)
                } else {
                    failBlock()
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            failBlock()
        }
    }
    
    //MARK: - 上传试乘试驾图片到七牛
    /// 上传试乘试驾图片到七牛
    ///
    /// - Parameters:
    ///   - image: 上传的图片
    ///   - block: 回调是否成功，上传成功后的key
    func upLoadTestDriveImage(_ image: UIImage, block: @escaping (_ success: Bool, _ key: String?,_ prefix:String?)->Void, progressBlock: @escaping QNUpProgressHandler) {
        getTestDriveUpToken({ (token, key, prefix) in
            if let data = image.compreseImage() {
                self.uploadManager?.put(data, key: key + ".jpg", token: token, complete: { (info, key, response) in
                    if info?.isOK == true {
                        block(true,key, prefix)
                    } else {
                        showAlertMessage(info?.error.localizedDescription ?? "网络异常", MYWINDOW)
                        block(false,nil, nil)
                    }
                }, option: QNUploadOption(progressHandler: progressBlock))
            } else {
                block(false,nil, nil)
                showAlertMessage("图片转换失败", MYWINDOW)
            }
        }, failBlock: {
            block(false,nil, nil)
        })
    }
    
    
    /// 获取上传试乘试驾图片token
    ///
    /// - Parameter block: 回调token  key prefix
    func getTestDriveUpToken(_ block: @escaping (_ token:String,_ key:String,_ prefix:String)->Void, failBlock: @escaping NormalBlock) {
        if let user = SW_UserCenter.shared.user {
            SWSQiniuService.getTestDriveUpToken(user.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    //                    "token": "Fxe6dMk9hSlOd5N-dcpkfvuP1sQ-SfuixOPRS-1V:CCtCARK1MCdcDgl4Df0HX1p_hEo=:eyJzY29wZSI6InlyLW9hLXRlc3QiLCJkZWFkbGluZSI6MTUyMzkzNDczMH0=",
                    //                    "key": "portrait/2/1523931130871",
                    block(json["token"].stringValue, json["key"].stringValue, json["imagePrefix"].stringValue)
                } else {
                    failBlock()
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            failBlock()
        }
    }
    
    
    //MARK: - 上传客户头像到七牛
    /// 上传客户头像图片到七牛
    ///
    /// - Parameters:
    ///   - image: 上传的图片
    ///   - block: 回调是否成功，上传成功后的key
    func upLoadCustomerPortraitImage(_ customerId: String, image: UIImage, block: @escaping (_ success: Bool, _ key: String?,_ prefix:String?)->Void, progressBlock: @escaping QNUpProgressHandler) {
        getCustomerPortraitUpToken({ (token, key, prefix) in
            if let data = image.compreseImage() {
                self.uploadManager?.put(data, key: key + ".jpg", token: token, complete: { (info, key, response) in
                    if info?.isOK == true {
                        block(true,key, prefix)
                    } else {
                        showAlertMessage(info?.error.localizedDescription ?? "网络异常", MYWINDOW)
                        block(false,nil, nil)
                    }
                }, option: QNUploadOption(progressHandler: progressBlock))
            } else {
                block(false,nil, nil)
                showAlertMessage("图片转换失败", MYWINDOW)
            }
        }, failBlock: {
            block(false,nil, nil)
        }, customerId: customerId)
    }
    
    
    /// 获取上传客户头像图片token
    ///
    /// - Parameter block: 回调token  key prefix
    func getCustomerPortraitUpToken(_ block: @escaping (_ token:String,_ key:String,_ prefix:String)->Void, failBlock: @escaping NormalBlock, customerId: String) {
        
        SWSQiniuService.getCustomerPortraitUpToken(customerId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                //                    "token": "Fxe6dMk9hSlOd5N-dcpkfvuP1sQ-SfuixOPRS-1V:CCtCARK1MCdcDgl4Df0HX1p_hEo=:eyJzY29wZSI6InlyLW9hLXRlc3QiLCJkZWFkbGluZSI6MTUyMzkzNDczMH0=",
                //                    "key": "portrait/2/1523931130871",
                block(json["token"].stringValue, json["key"].stringValue, json["imagePrefix"].stringValue)
            } else {
                failBlock()
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
       
    }
    
    
    //MARK: - 上传工作报告头像
    /// 上传工作报告图片到七牛
    ///
    /// - Parameters:
    ///   - image: 上传的头像
    ///   - block: 回调是否成功，上传成功后的key
    func upLoadAttachmentContractImage(_ image: UIImage, block: @escaping (_ success: Bool, _ key: String?,_ prefix:String?)->Void, progressBlock: @escaping QNUpProgressHandler) {
        getAttachmentContractUpToken({ (token, key, prefix) in
            if let data = image.compreseImage() {
                self.uploadManager?.put(data, key: key + ".jpg", token: token, complete: { (info, key, response) in
                    if info?.isOK == true {
                        block(true,key, prefix)
                    } else {
                        showAlertMessage(info?.error.localizedDescription ?? "网络异常", MYWINDOW)
                        block(false,nil, nil)
                    }
                }, option: QNUploadOption(progressHandler: progressBlock))
            } else {
                block(false,nil, nil)
                showAlertMessage("图片转换失败", MYWINDOW)
            }
        }, failBlock: {
            block(false,nil, nil)
        })
    }
    
    
    /// 获取上传工作报告图片token
    ///
    /// - Parameter block: 回调token  key
    func getAttachmentContractUpToken(_ block: @escaping (_ token:String,_ key:String,_ prefix:String)->Void, failBlock: @escaping NormalBlock) {
        if let user = SW_UserCenter.shared.user {
            SWSQiniuService.getAttachmentContractUpToken(user.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    //                    "token": "Fxe6dMk9hSlOd5N-dcpkfvuP1sQ-SfuixOPRS-1V:CCtCARK1MCdcDgl4Df0HX1p_hEo=:eyJzY29wZSI6InlyLW9hLXRlc3QiLCJkZWFkbGluZSI6MTUyMzkzNDczMH0=",
                    //                    "key": "portrait/2/1523931130871",
                    block(json["token"].stringValue, json["key"].stringValue, json["imagePrefix"].stringValue)
                } else {
                    failBlock()
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            failBlock()
        }
    }
}




class SWSQiniuRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/qiniu"
        }
        set {
            super.apiURL = newValue
        }
        
    }
    override var encryptAPI: Bool {
        get {
            return false
        }
        set {
            super.encryptAPI = newValue
        }
    }
}

class SWSQiniuService: NSObject {
    
    // 获取员工基本信息  post   重新登录时用于更新userinfo
    class func getUpToken(_ staffId: Int) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "getUpToken.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //  获取附件上传token
    class func getAttachmentContractUpToken(_ staffId: Int) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "getAttachmentContractUpToken.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 获取工作报告token
    class func getWorkReportUpToken(_ staffId: Int) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "getWorkReportUpToken.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 获取试乘试驾token
    class func getTestDriveUpToken(_ staffId: Int) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "getTestDriveUpToken.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 获取客户头像上传token
    class func getCustomerPortraitUpToken(_ customerId: String) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "getCustomerPortraitUpToken.json")
        request["customerId"] = customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }

    // "imgUrls":"图片url/图片url 用逗号分隔开"   批量删除上传七牛的图片
    class func imgBatchDelete(_ imgUrls: String) -> SWSQiniuRequest {
        let request = SWSQiniuRequest(resource: "imgBatchDelete.json")
        request["imgUrls"] = imgUrls
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
}
