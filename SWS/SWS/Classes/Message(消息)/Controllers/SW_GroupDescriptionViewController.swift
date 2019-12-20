//
//  SW_GroupDescriptionViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_GroupDescriptionViewController: FormViewController {
    
    private var isRequesting = false
    
    private var groupId = 0
    private var groupDescription = ""
    private var isGroupOwner = false
    
    init(_ groupId: Int, groupDescription: String, isGroupOwner: Bool) {
        self.groupId = groupId
        self.groupDescription = groupDescription
        self.isGroupOwner = isGroupOwner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    private func formConfig() {
        
        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        tableView.rowHeight = UITableView.automaticDimension
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
//            cell.titleLb.textColor = UIColor.v2Color.darkGray
//            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
        navigationItem.title = NSLocalizedString("群说明", comment: "")
        if isGroupOwner {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneAction(_:)))
        }
    }
    
    private func createTableView() {
        form = Form()
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {30}
                header.onSetupView = { view, _ in
                    view.title = ""
                }
                section.header = header
            }
        if isGroupOwner {
            form.last!
                <<< SW_CommenTextViewRow("group Description")  {
                    $0.placeholder = "请填写群说明"
                    $0.value = groupDescription
                    $0.maximumTextLength = 300
                    $0.rawTitle = "群说明"
                    $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                        self?.form.rowBy(tag: "group Description")?.reload()
                    }
                    }.onChange { [weak self] in
                        self?.groupDescription = $0.value ?? ""
            }
        } else {
            form.last!
                <<< SW_StaffInfoRow("group Description") {
                    $0.rowTitle = NSLocalizedString("群说明   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = groupDescription.isEmpty ? "未设置" : groupDescription
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func doneAction(_ sender: UIButton) {
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在保存", in: self.view)
        
        SW_GroupService.saveGroupRemark(groupId, remark: groupDescription).response({ (json, isCache, error) in
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
            if let _ = json as? JSON, error == nil {
                NotificationCenter.default.post(name: NSNotification.Name.Ex.GroupDescriptionHadChange, object: nil, userInfo: ["groupId": self.groupId, "groupDescription": self.groupDescription])
                showAlertMessage("保存成功", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
}

extension SW_GroupDescriptionViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
