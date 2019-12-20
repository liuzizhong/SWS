//
//  SW_TestDriveEvaluationOneViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_TestDriveEvaluationOneViewController: FormViewController {
    
    private var isRequesting = false
    
    var comment = SW_TestDriveCommentModel()
    
    init(_ recordId: String, customerId: String) {
        comment.recordId = recordId
        comment.customerId = customerId
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
        
        navigationItem.title = NSLocalizedString("本次接待信息", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneAction(_:)))
        
    }
    
    private func createTableView() {
        form = Form()
            
        +++
        Eureka.Section() { section in
            var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
            header.height = {70}
            header.onSetupView = { view, _ in
                view.title = "试乘/试驾"
            }
            section.header = header
            }
            
            <<< SW_CommenTextViewRow("Other opinions")  {
                $0.placeholder = "请填写试驾反馈"
                $0.value = comment.testDriveContent
                $0.maximumTextLength = 300
                $0.rawTitle = "试驾反馈"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "Other opinions")?.reload()
                }
                $0.cell.textView.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.comment.testDriveContent = $0.value ?? ""
            }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func doneAction(_ sender: UIButton) {

        if comment.testDriveContent.isEmpty {
            showAlertMessage("请填写试驾反馈", MYWINDOW)
            (form.rowBy(tag: "Other opinions") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }

        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在评价", in: self.view)
        SW_AddressBookService.saveTestDriveContent(comment).response({ (json, isCache, error) in
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
            if let json = json as? JSON, error == nil {
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEndTryDriving, object: nil, userInfo: ["customerId": self.comment.customerId, "endDate": json["endDate"].doubleValue])
                showAlertMessage("评价成功", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    
}

extension SW_TestDriveEvaluationOneViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
