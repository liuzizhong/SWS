//
//  SW_PersonalMessageViewController.swift
//  SWS
//
//  Created by jayway on 2018/1/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//  [个人信息控制器] -> [我的控制器] -> [SWS]

import Eureka

/// 个人资料编辑器
class SW_PersonalMessageViewController: FormViewController {

    private var user = SW_UserCenter.shared.user
    
    private var hobbyIndexPath = IndexPath(row: 2, section: 0)
    
    private var specialtyIndexPath = IndexPath(row: 2, section: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("个人信息", comment: "")
        formConfig()
        updateUserInfo()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.shadowImage = UIImage.image(solidColor: #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1), size: CGSize(width: 1, height: 1.0 / UIScreen.main.scale))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()//UIImage.image(solidColor: #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1), size: CGSize(width: 1, height: 1.0 / UIScreen.main.scale))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Action
    private func formConfig() {
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
        
        ImageRow.defaultCellUpdate = { (cell, row) in
            cell.textLabel?.textColor = UIColor.mainColor.darkBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
    }
    
    private func updateUserInfo() {
        SWSLoginService.updateUserInfo(user!.id).response { (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                // token有效  会返回更新用户信息
                if let _ = json.dictionary {
                    SW_UserCenter.shared.user?.updateUserData(json)
                    self.user = SW_UserCenter.shared.user
                    self.createTableView()
                }
            }
        }
    }
    
    private  func createTableView() {
        form = Form()
            +++
            Eureka.Section()
            <<< SW_PersionInfoRow("My Icon") {
                $0.value = user?.portrait
                }.onCellSelection({ [weak self] (cell, row) in
                    SW_ImagePickerHelper.shared.showPicturePicker({ (image) in
                        self?.handleImage(image)
                    })
                })
        
        form +++//不可改项
            Eureka.Section()
       
            <<< SW_CommenLabelRow("real Name") {
                $0.rawTitle = NSLocalizedString("姓名", comment: "")
                $0.value = user?.realName
            }
            <<< SW_CommenLabelRow("position") {
                $0.rawTitle = NSLocalizedString("职务", comment: "")
                $0.value = user?.position
            }
            <<< SW_CommenLabelRow("department Name") {
                $0.rawTitle = NSLocalizedString("部门", comment: "")
                $0.value = user?.departmentName
            }
            <<< SW_CommenLabelRow("business Unit Name") {
                $0.rawTitle = NSLocalizedString("单位", comment: "")
                $0.value = user?.businessUnitName
            }
            <<< SW_CommenLabelRow("region Info") {
                $0.rawTitle = NSLocalizedString("分区", comment: "")
                $0.value = user?.regionInfo
            }
            <<< SW_CommenLabelRow("Sex") {
                $0.rawTitle = NSLocalizedString("性别", comment: "")
                $0.value = user?.sex.rawTitle
        }
        
        
        form +++//可控制选项
            Eureka.Section()
        var count = 0
        
        if user?.birthdayString.isEmpty == false {
            form.last!
            <<< SW_CommenLabelRow("birthday") {
                $0.rawTitle = NSLocalizedString("生日", comment: "")
                $0.value = user?.birthdayString ?? ""
            }
            count += 1
        }
        
        if user?.businessNum.isEmpty == false {
            form.last!
                <<< SW_CommenLabelRow("businessNum") {
                    $0.rawTitle = NSLocalizedString("业务号码", comment: "")
                    $0.value = user?.businessNum ?? ""
            }
            count += 1
        }
        
        form.last!
            <<< SW_HobbyRow("hobby") {
                $0.rowTitle = NSLocalizedString("爱好", comment: "")
                $0.isShowBottomLine = true
                $0.tapBlock = { [weak self] in
                    self?.tapHobbyAction()
                }
                $0.value = user?.hobby ?? ""
                $0.cell.selectionStyle = .none
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.tapHobbyAction()
                })
        hobbyIndexPath = IndexPath(row: count, section: 2)
        count += 1
        
        form.last!
            <<< SW_HobbyRow("specialty") {
                $0.rowTitle = NSLocalizedString("特长", comment: "")
                $0.value = user?.specialty ?? ""
                $0.isShowBottomLine = true
                $0.tapBlock = { [weak self] in
                    self?.tapSpecialtyAction()
                }
                $0.cell.selectionStyle = .none
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.tapSpecialtyAction()
                })
        specialtyIndexPath = IndexPath(row: count, section: 2)
        
        tableView.reloadData()
    }
    
    //最后的处理  上传图片  上传服务器
    private func handleImage(_ selectImage: UIImage) {
        //上传至七牛后，将七牛返回的key上传至服务端。
        SWSUploadManager.share.upLoadPortrait(selectImage) { (success, key) in
            if let key = key, success {
                PrintLog("handleImagePicker--\(key)")
                
                SWSLoginService.setUserInfo(SW_UserCenter.shared.user?.id ?? 0, type: .portrait, content: key).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        //                        上传成功   服务端返回头像链接   更新userinfo   本地缓存也要更新
                        SW_UserCenter.shared.user?.portrait = json["portrait"].stringValue
                        //自己修改头像 更新一下聊天缓存
                        UserCacheManager.updateMyAvatar(json["portrait"].stringValue)
                        showAlertMessage(InternationStr("头像修改成功"), MYWINDOW)
                        SW_UserCenter.shared.user?.updateUserDataToCache()
                        //修改头像后需通知 刷新数据
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserPortraitHadChange, object: nil)
                        
                        if let url = URL(string: json["portrait"].stringValue) {
                            guard let imageRow: SW_PersionInfoRow = self.form.rowBy(tag: "My Icon") else { return }
                            imageRow.cell.iconImageView.sd_setImage(with: url)
                        }
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            }
        }
    }
    
    private func tapHobbyAction() {
        if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SelectTagViewController") as? SW_SelectTagViewController {
            vc.type = .hobby
            vc.selectTag = self.user?.hobby.zzComponents(separatedBy: "_") ?? []
            vc.sureBlock = { (tagString) in
                SWSLoginService.setUserInfo(self.user?.id ?? 0, type: .hobby, content: tagString).response({ (json, isCache, error) in
                    if  error == nil {
                        self.user?.hobby = tagString
                        let row = self.form.rowBy(tag: "hobby") as! SW_HobbyRow
                        row.value = tagString
                        row.reload()
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)//self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func tapSpecialtyAction() {
        if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SelectTagViewController") as? SW_SelectTagViewController {
            vc.type = .specialty
            vc.selectTag = self.user?.specialty.zzComponents(separatedBy: "_") ?? []
            vc.sureBlock = { (tagString) in
                SWSLoginService.setUserInfo(self.user?.id ?? 0, type: .specialty, content: tagString).response({ (json, isCache, error) in
                    if error == nil {
                        self.user?.specialty = tagString
                        let row = self.form.rowBy(tag: "specialty") as! SW_HobbyRow
                        row.value = tagString
                        row.reload()
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    private var cacheHeight = [String:CGFloat]()
    
    private func calculateTableCellHeight(_ tagString: String) -> CGFloat {
        if tagString.isEmpty { return 49 }
        if let height = cacheHeight[tagString] {
            return height
        }
        let tags = tagString.zzComponents(separatedBy: "_")
        let screenW = SCREEN_WIDTH
        //处理布局的时候需要调整
        let lineSpacing:CGFloat = 8
        let interitemSpacing:CGFloat = 8
        let edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)
        
        var lastCellFrame = CGRect.zero
        var frame: CGRect
        
        for tag in tags {
            let maxW = screenW - 30
            let textSize = NSString(string: tag).size(withAttributes: [NSAttributedString.Key.font:Font(14)])
            let itemSize = CGSize(width: min(textSize.width + 11 * 2.0, maxW), height: 28)
            
            if lastCellFrame == CGRect.zero {
                frame = CGRect(x: edgeInset.left, y: edgeInset.top, width: itemSize.width, height: itemSize.height)
            } else {
                frame = CGRect(x: lastCellFrame.maxX + lineSpacing, y: lastCellFrame.origin.y, width: itemSize.width, height: itemSize.height)
                if frame.maxX + edgeInset.right > screenW {
                    frame = CGRect(x: edgeInset.left, y: lastCellFrame.maxY + interitemSpacing, width: itemSize.width, height: itemSize.height)
                }
            }
            
            lastCellFrame = frame
        }
        cacheHeight[tagString] = lastCellFrame.maxY + edgeInset.bottom + 55
        return lastCellFrame.maxY + edgeInset.bottom + 55
    }
}


// MARK: - TableViewDelegate
extension SW_PersonalMessageViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == hobbyIndexPath {
            return calculateTableCellHeight(user?.hobby ?? "")
        } else if indexPath == specialtyIndexPath {
             return calculateTableCellHeight(user?.specialty ?? "")
        }
        if indexPath.section == 0 {
            return 120
        }
        return 89
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 45
        }
        return CGFloat.leastNormalMagnitude
    }
}



