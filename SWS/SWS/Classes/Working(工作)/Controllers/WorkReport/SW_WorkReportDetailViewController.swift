//
//  SW_WorkReportDetailViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/12.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkReportDetailViewController: FormViewController {
    
    private var ownerType = WorkReportOwner.received
    
    private var type = WorkReportType.day
    
    /// 将要显示的model--存放数据
    private var reportModel: SW_WorkReportModel!
    
    private var reportId = ""
    
    private var titleStr = ""
    
    private lazy var commentView: SW_WorkReportCommentView = {
        let comment = SW_WorkReportCommentView()
        comment.commentBtnBlock = { [weak self] in
            self?.commentAction()
        }
        return comment
    }()
    
    //MARK: - 初始化部分
    /// 初始化方法
    ///
    /// - Parameter reportId: 需要显示的报表ID
    init(_ reportId: String, type: WorkReportType, ownerType: WorkReportOwner) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.ownerType = ownerType
        self.reportId = reportId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        requestReportDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - 请求数据
    private func requestReportDetail() {
        var request: SWSRequest!
        switch ownerType {
        case .received:
            request = SW_WorkingService.getReceiveWorkReportDetail(reportId)
        default:
            request = SW_WorkingService.getMineWorkReportDetail(reportId)
        }
        ///请求详情时如果是我的报告，清空红点
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                if json["data"]["type"].intValue == 1 {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserCantLookWorkReport, object: nil, userInfo: ["workReportType": self.type])
                    showAlertMessage(json["msg"].stringValue, MYWINDOW!)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.reportModel = SW_WorkReportModel(self.type, ownerType: self.ownerType, json: json["data"])
                    if self.ownerType == .received {
                        self.titleStr = "\(self.reportModel.reporterName)的" + self.type.rawTitle
                    } else {//显示了我的工作报告，通知清空红点
                        self.titleStr = "我的" + self.type.rawTitle
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadLookMineWorkReport, object: nil, userInfo: ["workReportType": self.type])
                    }
                    self.addEditButton()
                    self.addCheckTextView()
                    self.createTableView()
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    
    //MARK: - 设置tableview数据源
    private func formConfig() {
        view.backgroundColor = UIColor.white

        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 140, right: 0)
        //用户编辑了报告，刷新数据页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requestReportDetail()
        }
        ///用户编辑过程中有人审阅了，编辑失败，并刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.WorkReportByReviewed, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requestReportDetail()
        }
    }
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = self?.titleStr ?? ""
                }
                section.header = header
        }
        
        switch type {
        case .day:
            form.last!
                <<< SW_WorkTypeDetailRow("workTypes") {
                    $0.value = reportModel.workTypes.map({ return $0.name })
                    $0.cell.dateLabel.text = Date.dateWith(timeInterval: reportModel.createDate).messageContentTimeString()
                }
        case .month,.year:
            form.last!
                <<< SW_WorkReportTitleDetailRow("title") {//标题
                    $0.cell.titleLabel.text = reportModel.title
                    $0.cell.dateLabel.text = Date.dateWith(timeInterval: reportModel.createDate).messageContentTimeString()
                }
        }
        
        form.last!
            <<< SW_WorkReportContentDetailRow("content")  {
                $0.cell.contentLabel.text = reportModel.content
            }
            
        if reportModel.images.count > 0 {
            form.last!
            <<< SW_WorkReportImageDetailRow("images") {
                $0.value = reportModel.images
            }
        }
        
        ////审阅意见
        form
            +++
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<SW_CheckDetailSectionHeader>(.class)
                header.height = {50}
                header.onSetupView = { view, _ in
                    view.title = "审阅意见"
                    view.checkCountLb.isHidden = self?.ownerType == .received
                    view.checkCountLb.text = "审阅情况(\(self?.reportModel.checkCount ?? 0)/\(self?.reportModel.receiverTotal ?? 0))"
                    view.nextImageView.isHidden = self?.ownerType == .received
                }
                section.header = header
            }
        
        switch ownerType {
        case .mine:
            /// 将有评论的接收者过滤出来  有则循环添加row
            let commens = reportModel.receivers.filter({ return $0.isCheck })
            if commens.count > 0 {
                for index in 0..<commens.count {
                    form.last!
                        <<< SW_WorkReportDetailCommentRow("commens\(index)") {
                            $0.value = commens[index]
                            }.onCellSelection({ [weak self] (cell, row) in
                                self?.navigationController?.pushViewController(SW_StaffInfoViewController(commens[index].id), animated: true)
                            })
                }
            } else {///无数据，添加暂时评论row
                form.last!
                    <<< SW_NoCommenRow("No CommentRow") {
                        $0.cell.tipLabel.text = "该报告还没有相关审阅意见"
                }
            }
        case .received:
            if reportModel.isCheck {//我审阅了
                form.last!
                    <<< SW_WorkReportDetailCommentRow("commens\(index)") {
                        if let url = URL(string: SW_UserCenter.shared.user?.portrait ?? "") {
                            $0.cell.iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
                        } else {
                            $0.cell.iconImageView.image = UIImage(named: "icon_personalavatar")
                        }
                        $0.cell.nameLabel.text = SW_UserCenter.shared.user?.realName ?? ""
                        $0.cell.messageLable.text = reportModel.comment
                        $0.cell.dateLabel.text = Date.dateWith(timeInterval: reportModel.checkDate).messageContentTimeString()
                        }.onCellSelection({ [weak self] (cell, row) in
                            self?.navigationController?.pushViewController(SW_StaffInfoViewController(SW_UserCenter.shared.user?.id ?? 0), animated: true)
                        })
            } else {//还没审阅
                form.last!
                    <<< SW_NoCommenRow("No CommentRow") {
                        $0.cell.tipLabel.text = "您还没有发表相关审阅意见"
                }
            }
        }
        
        
        tableView.reloadAndFadeAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    //MARK: - 编辑按钮点击
    private func addEditButton() {
        if reportModel.isModify, ownerType == .mine {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editAction(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func addCheckTextView() {
        if ownerType == .received, !reportModel.isCheck {//还未审阅过
            PrintLog("添加审阅输入框")
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            
            view.addSubview(commentView)
            commentView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    @objc private func editAction(_ sender: UIButton) {
        self.navigationController?.pushViewController(SW_EditWorkReportViewController(type, reportModel: reportModel), animated: true)
    }
    
    private var isRequesting = false
    
    private func commentAction() {
        guard !isRequesting else {
            return
        }
        isRequesting = true
        
        SW_WorkingService.saveWorkReportRecord(reportId, comment: commentView.getCommentText()).response({ (json, isCache, error) in
            if error == nil {
                self.requestReportDetail()
                showAlertMessage("审阅成功", MYWINDOW)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCommentWorkReport, object: nil, userInfo: ["workReportType": self.type])
                self.commentView.resignFirstResponder()
                self.commentView.removeFromSuperview()
            } else if let json = json as? JSON, json["code"].intValue == 1 {
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserCantLookWorkReport, object: nil, userInfo: ["workReportType": self.type])
                showAlertMessage(json["msg"].stringValue, MYWINDOW!)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            self.isRequesting = false
        })
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! CGFloat
        let endKeyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        
        if endKeyboardRect.origin.y == SCREEN_HEIGHT {//收起键盘  会通知两次？原因未知
            PrintLog("收起键盘")
            commentView.setupCommentViewState(duration, toState: .hideInput)
            commentView.snp.remakeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
            }
            
        } else {//弹起键盘或修改键盘
            PrintLog("弹起键盘或修改键盘")
            commentView.setupCommentViewState(duration, toState: .showInput)
            commentView.snp.remakeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(endKeyboardRect.origin.y - SCREEN_HEIGHT)
            }
        }
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.commentView.layoutIfNeeded()
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
}

// MARK: - TableViewDelegate
extension SW_WorkReportDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
