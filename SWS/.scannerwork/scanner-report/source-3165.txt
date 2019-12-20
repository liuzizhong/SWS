//
//  SW_FeedBackViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/12.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_FeedBackViewController: FormViewController {
    
    private var isRequesting = false
    
    private var titleStr = "" {
        didSet {
            checkCommitBtnEnble()
        }
    }
    private var content = "" {
        didSet {
            checkCommitBtnEnble()
        }
    }
    
    private weak var commitBtn: UIButton?
    
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
        rowKeyboardSpacing = 150
        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(cancelBtnAction(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "我的反馈", style: .plain, target: self, action: #selector(myListAction(_:)))
    }
    
    private func createTableView() {
        form = Form()
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "反馈"
                }
                section.header = header
            }
            
            
            <<< SW_CommenTextViewRow("titleStr")  {
                $0.placeholder = "请填写标题"
                $0.value = titleStr
                $0.maximumTextLength = 30
                $0.rawTitle = "标题"
                $0.maximumHeight = 50
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "titleStr")?.reload()
                }
                $0.cell.textView.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.titleStr = $0.value ?? ""
            }
            
            <<< SW_CommenTextViewRow("content")  {
                $0.placeholder = "请填写反馈内容"
                $0.value = content
                $0.maximumTextLength = 300
                $0.rawTitle = "内容"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "content")?.reload()
                }
                }.onChange { [weak self] in
                    self?.content = $0.value ?? ""
        }
        
            +++
            Section() { [weak self] section in
                var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                header.height = {150}
                header.onSetupView = { view, _ in
                    view.leftConstraint.constant = 15
                    view.rightConstraint.constant = 15
                    self?.commitBtn = view.button
                    view.button.layer.borderWidth = 0
                    view.button.isEnabled = self?.titleStr.isEmpty == false && self?.content.isEmpty == false
                    view.button.setTitle("提交反馈", for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                    view.button.setTitleColor(UIColor.white, for: UIControl.State())
                    view.button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
                    view.button.titleLabel?.font = Font(16)
                    view.actionBlock = {
                        /// 调用发送消息按钮
                        self?.commitBtnAction()
                    }
                }
                section.header = header
        }
    }
    
    @objc func cancelBtnAction(_ sender: UIBarButtonItem) {
        alertControllerShow(title: "是否退出编辑？", message: nil, rightTitle: "是", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "否", leftBlock: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func myListAction(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SuggestionListViewController") as! SW_SuggestionListViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //        提交反馈
    func commitBtnAction() {
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在提交", in: self.view)
        SW_SuggestionService.saveSuggestion(SW_UserCenter.shared.user?.id ?? 0, content: content, tittle: titleStr).response { (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if error == nil {
                showAlertMessage("提交成功", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
            }
        }
    }
    
    func checkCommitBtnEnble() {
        commitBtn?.isEnabled = titleStr.isEmpty == false && content.isEmpty == false
    }
    
}

extension SW_FeedBackViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}




