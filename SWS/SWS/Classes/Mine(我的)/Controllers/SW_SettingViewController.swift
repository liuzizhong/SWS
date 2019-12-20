//
//  SW_SettingViewController.swift
//  SWS
//
//  Created by jayway on 2018/1/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//  [设置控制器] -> [我的控制器] -> [SWS]

import UIKit

class SW_SettingViewController: UITableViewController {
    
    @IBOutlet weak var versionLb: UILabel!
    
    @IBOutlet weak var redDotView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        redDotView.layer.cornerRadius = 3
        redDotView.isHidden = !SWSApiCenter.isHadNewVersion
        versionLb.text = "版本V\(SWSApiCenter.getSWSVersion())"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    //MARK: -点击cell调用方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0://账号
            navigationController?.pushViewController(SW_SettingAccountViewController(), animated: true)
            
        case 1://修改密码
            
            
            let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SettingPhoneChangePwdViewController") as! SW_SettingPhoneChangePwdViewController
            navigationController?.pushViewController(vc, animated: true)
        case 2://消息提醒
            navigationController?.pushViewController(SW_SettingMessageViewController(style: .grouped), animated: true)
            
        case 3://聊天设置
            navigationController?.pushViewController(SW_ChatSettingsViewController(style: .grouped), animated: true)
            
        case 4://清除缓存
            clearCache()
            
        case 5://版本更新，前往App Store
            if SWSApiCenter.isHadNewVersion {
                UIApplication.shared.open(scheme: AppStoreLink)
            } else {
                showAlertMessage("当前已是最新版本", MYWINDOW)
            }
            
        case 6:
            logoutBtnAction()
        default:
            break
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch (indexPath.section,indexPath.row) {
        case (2,1): //版本更新，前往App Store
            if !redDotView.isHidden {
                redDotView.backgroundColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
            }
        default:
            break
        }
    }
    
    func logoutBtnAction() {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        let alertController = UIAlertController.init(title: nil, message: "退出效率+后，您将不再收到来自效率+的消息", preferredStyle: .actionSheet)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let quitAction = UIAlertAction(title: "确认", style: .destructive) { (alert) -> Void in
            //点击退出登录时调用
            SWSLoginService.delLoginToken(SW_UserCenter.shared.user?.token ?? "").response { (json, isCache, error) in
            }
            SW_UserCenter.logout(nil)
        }
        
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(quitAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func clearCache() {
        let alertController = UIAlertController.init(title: InternationStr("确认清空缓存数据？"), message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let quitAction = UIAlertAction(title: "确认", style: .destructive) { (alert) -> Void in
            //清空缓存
            PrintLog("清空缓存")
//            // clear with progress
//            [imageCache.diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
//                CGFloat progress = removedCount / (float)totalCount;
//                } endBlock:^(BOOL error) {
//                // success
//                }];
            //YYIMageCache 清除缓存
            let yyImageCache = YYWebImageManager.shared().cache
            yyImageCache?.memoryCache.removeAllObjects()
            yyImageCache?.diskCache.removeAllObjects()
            
            //SDKWebImage清除缓存
            EMSDImageCache.shared().clearMemory()
            EMSDImageCache.shared().clearDisk()
            
            showAlertMessage("清除缓存成功", self.view)
        }
        
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
   

}
