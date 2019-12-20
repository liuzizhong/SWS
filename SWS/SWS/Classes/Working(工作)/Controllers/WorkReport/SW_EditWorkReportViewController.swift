//
//  SW_EditWorkReportViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_EditWorkReportViewController: FormViewController {
    
    /// 工作报告的类型
    private var type = WorkReportType.day
    
    /// 将要显示的model--存放数据
    var reportModel: SW_WorkReportModel!
    
    /// 用于存放这次新上传到七牛的keys  deinit时需要删除，删除前要判断是否有进行保存，保存了就不删除
    private var addKeys = [String]()
    
    private var contentHeight: CGFloat = 123.0
    
    /// 用于销毁时判断是否有进行保存操作没有要删除key
    private var hadSave = false
    
    private var isRequesting = false
    ///控制添加的图片与接收人的最大数量
    private var maxPictureCount = 8
    private var maxMemberCount = 8
    private let imageColumn = 5
    
    let rangeCache = YYCache(path: documentPath + "/Ranges.db")
    /// 存储上次push的接收人的key
    private let lastPushReceiversKey = "lastPushReceivers\(SW_UserCenter.getUserCachePath())"
    /// 储存草稿数据的key
    private var draftKey = ""
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - reportType: 报告类型
    ///   - reportModel: 编辑的报告
    init(_ reportType: WorkReportType, reportModel: SW_WorkReportModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.type = reportType
        draftKey = "draft_\(type.rawValue)_\(SW_UserCenter.getUserCachePath())"
        
        if let report = reportModel {//后面调 
            self.reportModel = report.copy() as? SW_WorkReportModel
        } else {
            /// 这里判断是否有存草稿
            if let report = rangeCache?.object(forKey: draftKey) as? SW_WorkReportModel {
                self.reportModel = report
                addKeys = report.images.map({ return $0.replacingOccurrences(of: report.imagePrefix, with: "") })
            } else {
                self.reportModel = SW_WorkReportModel(reportType, ownerType: .mine)
                /// 如果没有接收人，则取上次--有草稿不取这个
                if let ranges = rangeCache?.object(forKey: lastPushReceiversKey) as? [SW_RangeModel] {
                    self.reportModel.receivers = ranges
                }
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setCanDragBack(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCanDragBack(false)
    }
    
    private func setCanDragBack(_ canDragBack: Bool) {
        if let nav = navigationController as? SW_NavViewController {
            nav.canDragBack = canDragBack
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 设置tableview数据源
    private func formConfig() {
        view.backgroundColor = UIColor.white

        navigationItem.title = NSLocalizedString(type.rawTitle, comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(commitAction(_:)))
        navigationController?.removeViewController([SW_SelectWorkTypeViewController.self])
        rowKeyboardSpacing = 89
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        
        //选人控件成功选人后回调通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.HadSelectPushMember, object: nil, queue: nil) { [weak self] (notifa) in
            let selectMembers = notifa.userInfo?["selectStaffs"] as! [SW_RangeModel]
            self?.reportModel.receivers = selectMembers
            self?.saveDraft()
            if let row = self?.form.rowBy(tag: "receiverIds") as? SW_PushMembersRow {
                row.cell.members = selectMembers
                row.reload()
            }
        }
    }
    
    fileprivate func createTableView() {
        /// 编辑时计算初始高度。
        var height = flat(reportModel.content.size(Font(16), width: SCREEN_WIDTH - 30).height)
        height = max(35.5, height)
        contentHeight = height + 87.5
        
        form = Form()
        switch type {
        case .day:
            form
                +++
                Eureka.Section()
                
                <<< SW_HobbyRow("workTypes") { [weak self] in
                    $0.rowTitle = NSLocalizedString("任务标签", comment: "")
                    $0.value = reportModel.workTypes.map({ return $0.name }).joined(separator: "_")
                    $0.tapBlock = {
                        self?.tapWorkTypesAction()
                    }
                    $0.cell.titleLb.font = Font(12)
                    $0.cell.titleLb.textColor = UIColor.v2Color.lightBlack
                    $0.cell.selectionStyle = .none
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.tapWorkTypesAction()
                    })
            
        case .month,.year:
            form
                +++
                Eureka.Section()
                
                <<< SW_CommenFieldRow("title") {
                    $0.rawTitle = NSLocalizedString("标题", comment: "")
                    $0.value = reportModel.title
                    $0.limitCount = 40
                    $0.cell.valueField.keyboardType = .default
                    $0.cell.valueField.placeholder = "输入标题"
                    }.onChange { [weak self] in
                        self?.reportModel.title = $0.value ?? ""
                        self?.saveDraft()
                }
            
        }
        
       form
        +++
            Eureka.Section()
        
        <<< SW_CommenTextViewRow("content")  {
            $0.placeholder = "输入\(type.rawTitle)内容"
            $0.rawTitle = "报告内容"
            $0.maximumTextLength = 300
            $0.value = reportModel.content
            $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                self?.contentHeight = textViewHeight + 87.5
                self?.form.rowBy(tag: "content")?.reload()
            }
            }.onChange { [weak self] in
                self?.reportModel.content = $0.value ?? ""
                self?.saveDraft()
        }
        
            +++
            Eureka.Section()
            <<< SW_SelectPictureRow("images") {
                $0.images = reportModel.images
                $0.column = CGFloat(imageColumn)
                $0.maxCount = maxMemberCount
                $0.didShouDownRow = { [weak self] (indexPath) in//删除图片  indexpath
                    //删除图片
                    self?.deleteImage(indexPath)
                }
                $0.didSelectAdd = { [weak self] in//点击添加图片。弹出图片选择器
                    SW_ImagePickerHelper.shared.showPicturePicker({ (img) in
                        dispatch_async_main_safe {
                            self?.handleImage(img)
                        }
                    }, cropMode: .none)
                }
            }
        
        +++
        Eureka.Section()
        <<< SW_PushMembersRow("receiverIds") {
            $0.cell.members = reportModel.receivers
            $0.cell.maxCount = maxMemberCount
            $0.cell.didShouDownRow = { [weak self] (indexPath) in
                //删除接收人
                self?.deleteReceiver(indexPath)
            }
            $0.cell.didSelectAdd = { [weak self]  in
                let vc = SW_SelectPeopleRangeViewController(nil, navTitle: "添加接收人", type: .addPushMember)
                vc.selectMember = self!.reportModel.receivers
                let nav = SW_NavViewController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true, completion: nil)
            }
        }

        tableView.reloadAndFadeAnimation()
    }
    
    /// 保存至草稿。
    func saveDraft() {
        if reportModel.id.isEmpty {/// 编辑不存草稿
            rangeCache?.setObject(reportModel, forKey: draftKey)
        }
    }
    
    deinit {
        ///删除未保存工作报告的keys，防止空间浪费 --- 需要判断是否保存了，没保存
        if !hadSave, addKeys.count > 0 {
            SWSQiniuService.imgBatchDelete(addKeys.joined(separator: ",")).response({ (json, isCache, error) in
            })
        }
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    //MARK: - 提交按钮点击
    @objc private func commitAction(_ sender: UIButton) {
        switch type {
        case .day:
            if reportModel.workTypes.count == 0 {
                showAlertMessage("请选择任务标签", MYWINDOW)
                return
            }
        default:
            if reportModel.title.isEmpty {
                showAlertMessage("请输入标题", MYWINDOW)
                (form.rowBy(tag: "title") as? SW_CommenFieldRow)?.showErrorLine()
                (form.rowBy(tag: "content") as? SW_CommenTextViewRow)?.showErrorLine()
                return
            }
        }
        
        if reportModel.content.isEmpty {
            showAlertMessage("请输入报告内容", MYWINDOW)
            (form.rowBy(tag: "content") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        
        if reportModel.receivers.count == 0 {
            showAlertMessage("请选择接收人", MYWINDOW)
            return
        }
        
        /// 添加一个判断是否有正在上传中的图片的逻辑，等全部上传完成后才可以提交
        if let row = self.form.rowBy(tag: "images") as? SW_SelectPictureRow, row.upImages.count > 0 {
            showAlertMessage("图片正在上传中...", MYWINDOW)
            return
        }
        
        ///工作报告只能修改一次，因此提示不可再更改   或者  =--///直接新建
        let msg = reportModel.id.isEmpty ? "你可以在7日内推送人批阅前修改本信息1次" : "你将不能再修改本信息"
        alertControllerShow(title: "您确定保存此报表信息吗？", message: msg, rightTitle: "确 定", rightBlock: { (_, _) in
            self.postRequest()
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    @objc private func backAction() {
        if reportModel.id.isEmpty {
            /// 新建
            alertControllerShow(title: "将此次编辑保留？", message: nil, rightTitle: "保留", rightBlock: { (controller, action) in
                self.addKeys.removeAll()///保留时不清空七牛中的图片，恢复草稿以后的逻辑会删除
                self.navigationController?.popViewController(animated: true)
            }, leftTitle: "不保留", leftBlock: { (controller, action) in
                /// 清空保存的草稿数据
                self.rangeCache?.removeObject(forKey: self.draftKey)
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            /// 编辑
            alertControllerShow(title: "您确定取消编辑此报表信息吗？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
                self.navigationController?.popViewController(animated: true)
            }, leftTitle: "取 消", leftBlock: nil)
        }
        
    }
    
    ///保存成功后的逻辑课优化
    private func postRequest() {
        guard !isRequesting else { return }
        QMUITips.showLoading("正在保存", in: self.view)
        isRequesting = true
        /// 保存s这个push的报告接收人
        rangeCache?.setObject(self.reportModel.receivers as NSCoding, forKey: lastPushReceiversKey)
        
        /// 如果到这里说明该填的都填了。  --提交新建订单报表 ----
        SW_WorkingService.saveWorkReport(reportModel).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                self.hadSave = true///该变量为true时不会删除上传的图片
                showAlertMessage("保存成功", MYWINDOW)//或者编辑
                self.rangeCache?.removeObject(forKey: self.draftKey)
                if self.reportModel.id.isEmpty {//新建
//                    if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_WorkReportMainViewController }) {
                        //                    通知刷新数据
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreatWorkReport, object: nil, userInfo: ["workReportType": self.type])
//                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
//                    }
                } else {//编辑 返回详情页
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEditWorkReport, object: nil, userInfo: ["workReportType": self.type, "title": self.reportModel.title, "content":self.reportModel.content, "receiverTotal":self.reportModel.receivers.count])
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                if let json = json as? JSON, json["code"].intValue == 8888 {
                    showAlertMessage(json["msg"].stringValue, MYWINDOW)
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.WorkReportByReviewed, object: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            }
        })
        
    }
    
    /// 点击工作标签row
    func tapWorkTypesAction() {
        if let vc = UIStoryboard(name: "Working", bundle: nil).instantiateViewController(withIdentifier: "SW_SelectWorkTypeViewController") as? SW_SelectWorkTypeViewController {
            vc.selectWork = reportModel.workTypes
            vc.isCanBack = false
            vc.sureBlock = { [weak self] (workTypes) in
                self?.reportModel.workTypes = workTypes
                guard let row = self?.form.rowBy(tag: "workTypes") as? SW_HobbyRow else { return }
                row.value = workTypes.map({ return $0.name }).joined(separator: "_")
                row.reload()
            }
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    }
    
    //MARK: - 图片选择相关逻辑
    // 最后的处理  上传图片  上传服务器
    // 上传至七牛后，将七牛返回的key上传至服务端。
    private func handleImage(_ selectImage: UIImage) {
        guard let row = self.form.rowBy(tag: "images") as? SW_SelectPictureRow else { return }
        if row.images.count + row.upImages.count >= maxPictureCount {
            return
        }
        row.upImages.append(selectImage)
        row.reload()
        
        SWSUploadManager.share.upLoadWorkReportImage(selectImage, block: { (success, key, prefix) in
            if let key = key, let prefix = prefix, success {
                //                上传成功
                self.addKeys.append(key)
                self.reportModel.imagePrefix = prefix
                self.reportModel.images.append(prefix+key)
                self.saveDraft()
                /// 找到对应的上传的image删除
                if let index = row.upImages.firstIndex(of: selectImage) {
                    row.upImages.remove(at: index)
                }
                row.successImage[prefix+key] = selectImage
                row.images = self.reportModel.images
                row.reload()
            } else {/// 上传失败
                showAlertMessage("上传失败,请重新选择", MYWINDOW)
                if let index = row.upImages.firstIndex(of: selectImage) {
                    row.upImages.remove(at: index)
                }
                row.reload()
            }
        }) { (key, progress) in
            /// 更新这个image对应cell的进度，根据图片找到对应的indexpath
            dispatch_async_main_safe {
                row.updateUpImagesProgress(image: selectImage, progress: progress)
            }
        }
    }
    
    private func deleteImage(_ indexPaht: IndexPath) {
        if self.reportModel.images.count > indexPaht.row {//删除的在正确范围内
            let key = self.reportModel.images[indexPaht.row].replacingOccurrences(of: self.reportModel.imagePrefix, with: "")
            self.reportModel.images.remove(at: indexPaht.row)
            saveDraft()
            //这次上传的删除
            if let index = addKeys.index(of: key) {
                addKeys.remove(at: index)
                //删除七牛空间中的图片---不是本次上传的不删除
                SWSQiniuService.imgBatchDelete(key).response({ (json, isCache, error) in
                })
            }
            //刷新页面
            if let row = self.form.rowBy(tag: "images") as? SW_SelectPictureRow {
                row.images = self.reportModel.images
                row.reload()
            }
        }
    }
    
    
    private func deleteReceiver(_ indexPaht: IndexPath) {
        if self.reportModel.receivers.count > indexPaht.row {//删除的在正确范围内
            self.reportModel.receivers.remove(at: indexPaht.row)
            saveDraft()
            //刷新页面
            if let row = self.form.rowBy(tag: "receiverIds") as? SW_PushMembersRow {
                row.cell.members = self.reportModel.receivers
                row.reload()
            }
        }
    }
    
    //MARK: - private method
    private func calculateMenberRowHeight() -> CGFloat {
        let memberCount =  min(maxMemberCount, reportModel.receivers.count + 1)
        let addCount = memberCount % 5 > 0 ? 1 : 0
        let colum = memberCount / 5 + addCount
        return CGFloat(76 * colum + 15 * (colum - 1) + 59)
    }
    
    private func calculateImagesRowHeight() -> CGFloat {
        guard let row = self.form.rowBy(tag: "images") as? SW_SelectPictureRow else { return 89 }
        let imageCount =  min(maxPictureCount, row.images.count + row.upImages.count + 1)
        let addCount = imageCount % imageColumn > 0 ? 1 : 0
        let colum = imageCount / imageColumn + addCount
        let height = Int((SCREEN_WIDTH - 70) / CGFloat(imageColumn))
        return CGFloat(height * colum + 10 * (colum - 1) + 52)
    }
    
    private var cacheHeight = [String:CGFloat]()
    
    private func calculateWorkTypeRowHeight(_ workString: String) -> CGFloat {
        if workString.isEmpty { return 49 }
        if let height = cacheHeight[workString] {
            return height
        }
        let works = workString.zzComponents(separatedBy: "_")
        //处理布局的时候需要调整
        let lineSpacing:CGFloat = 8
        let interitemSpacing:CGFloat = 8
        let edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)
        
        var lastCellFrame = CGRect.zero
        var frame: CGRect
        
        for work in works {
            let maxW = SCREEN_WIDTH - 30
            let textSize = NSString(string: work).size(withAttributes: [NSAttributedString.Key.font:Font(14)])
            let itemSize = CGSize(width: min(textSize.width + 11 * 2.0, maxW), height: 28)
            
            if lastCellFrame == CGRect.zero {
                frame = CGRect(x: edgeInset.left, y: edgeInset.top, width: itemSize.width, height: itemSize.height)
            } else {
                frame = CGRect(x: lastCellFrame.maxX + lineSpacing, y: lastCellFrame.origin.y, width: itemSize.width, height: itemSize.height)
                if frame.maxX + edgeInset.right > SCREEN_WIDTH {
                    frame = CGRect(x: edgeInset.left, y: lastCellFrame.maxY + interitemSpacing, width: itemSize.width, height: itemSize.height)
                }
            }
            
            lastCellFrame = frame
        }
        cacheHeight[workString] = lastCellFrame.maxY + edgeInset.bottom + 55
        return lastCellFrame.maxY + edgeInset.bottom + 55
    }
}

// MARK: - TableViewDelegate
extension SW_EditWorkReportViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if type == .day {
                return calculateWorkTypeRowHeight(reportModel.workTypes.map({ return $0.name }).joined(separator: "_"))
            } else {
                return 89
            }
        case 1:
            return contentHeight
        case 2:
            return calculateImagesRowHeight()
        case 3:
            return calculateMenberRowHeight()
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
