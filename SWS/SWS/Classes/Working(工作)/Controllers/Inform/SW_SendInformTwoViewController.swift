//
//  SW_SendInformTwoViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/2.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka
//import BRPickerView

class SW_SendInformTwoViewController: FormViewController {
    
    fileprivate let cache = YYCache(path: documentPath + "/informDraft.db")
    fileprivate var informTitle = ""
    fileprivate var content = ""
    fileprivate var fileBase64 = ""
    //自定义选择的范围    临时范围
    fileprivate var rangeManager: SW_RangeManager?
    //选择的消息类型
    fileprivate var type: InformType? {//有type才有范围
        didSet {
            if let type = type, type != oldValue, isViewLoaded {
                rangeManager = nil
                selectRange = nil
                commonContactRange = SW_RangeManager.getCommonContactRange(informType: type)
                tableView.reloadDataAndScrollOriginal({ [weak self] in
                    self?.createTableView()
                })
            }
        }
    }
    //常用发送范围列表
    fileprivate var commonContactRange = [SW_RangeManager]()
    //最终要发送的范围  为选择常用范围时就使用常用发送范围
    fileprivate var selectRange: SW_RangeManager?
    /// 是否发起请求
    private var isRequesting = false
    
    fileprivate lazy var imageSection: Section = {
        let section = Eureka.Section() { [weak self] section in
            var header = HeaderFooterView<SW_SummaryHeaderView>(.nibFile(name: "SW_SummaryHeaderView", bundle: nil))
            header.onSetupView = { view, _ in
                if let filebase64 = self?.fileBase64, !filebase64.isEmpty , let imageData = Data(base64Encoded: filebase64) {
                    let image = UIImage(data: imageData)
                    view.coverImgView.image = image
                    view.coverImgView.isHidden = false
                    view.addImageBtn.isHidden = true
                }
                view.selectImageBlock = { (image) -> Void in
                    self?.fileBase64 = image
                    self?.saveDraft()
                }
            }
            header.height = {123}
            section.header = header
        }
        return section
    }()
    
    init(_ title: String) {
        super.init(nibName: nil, bundle: nil)
        self.restoreDraft()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formConfig()
        createTableView(true)
    }
    
    deinit {
        PrintLog("deinit")
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
    
    //MARK: - Action
    private func formConfig() {

        navigationItem.title = InternationStr("新建公告")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelBtnAction(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(postBtnAction(_:)))
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        rowKeyboardSpacing = 89
        LabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.v2Color.lightGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell.height = { 64 }
        }
    }
    
    fileprivate func createTableView(_ becomeFirst: Bool = false) {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<SectionHeaderView>(.class)
                header.height = {10}
                header.onSetupView = { view, _ in
                    view.backgroundColor = UIColor.white
                }
                section.header = header
        }
        
            <<< SW_CommenTextViewRow("informTitle")  {
                $0.placeholder = "请输入公告标题"
                $0.value = informTitle
                $0.maximumTextLength = 30
                $0.rawTitle = "标题"
                $0.maximumHeight = 50
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "informTitle")?.reload()
                }
                if becomeFirst {
                    $0.cell.textView.becomeFirstResponder()
                }
                }.onChange { [weak self] in
                    self?.informTitle = $0.value ?? ""
                    self?.saveDraft()
            }
            
            <<< SW_CommenTextViewRow("content")  {
                $0.placeholder = "请输入公告内容"
                $0.value = content
                $0.maximumTextLength = 300
                $0.rawTitle = "公告内容"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "content")?.reload()
                }
                }.onChange { [weak self] in
                    self?.content = $0.value ?? ""
                    self?.saveDraft()
            }
         
            
        +++
        imageSection
            
        +++
        Eureka.Section()
        
        if type != nil {
            form.last!
                <<< LabelRow("send type2") {
                    $0.title = NSLocalizedString("发送类型", comment: "")
                    $0.value = type?.rawTitle ?? "选择类型"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        let dataSource = SW_UserCenter.shared.user!.auth.messageAuth[0].authDetails.map({ return $0.rawTitle })
                        BRStringPickerView.showStringPicker(withTitle: nil, on: MYWINDOW, dataSource: dataSource, defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
                            if let selectValue = selectValue as? String {
                                self?.type = InformType(selectValue)
                                self?.saveDraft()
                            }
                            })
                        
                    })
                
                
            form +++
                Eureka.Section() { section in
                    var header = HeaderFooterView<SectionHeaderView>(.class)
                    header.height = {34}
                    header.onSetupView = { view, _ in
                        view.backgroundColor = UIColor.white
                        view.titleView.font = Font(13)
                        view.titleView.textColor = UIColor.v2Color.lightGray
                        view.title = "选择发送范围"
                    }
                    section.header = header
                }
                
                
                <<< SW_TempInformRangeRow("send range") {
                    $0.value = rangeManager?.getSelectRangesPeopleCount() ?? "0人"
                    $0.isSelect = rangeManager == selectRange && rangeManager != nil
                    let row = $0
                    $0.nextBlock = { [weak self, weak row] in
                        guard let self = self else {  return }
                        guard let row = row else { return }
                        let selectVc = SW_SelectInformRangeViewController(self.type ?? .group, rangeManager: nil)
                        selectVc.selectSuccesBlock = { [weak self] (rangeManager, informType, isAddCommonRange) in
                            guard let self = self else { return }
                            if isAddCommonRange {
                                self.commonContactRange = SW_RangeManager.getCommonContactRange(informType: self.type ?? .group)
                                self.selectRange = self.commonContactRange.last
                                self.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                    self?.createTableView()
                                })
                            } else {
                                self.rangeManager = rangeManager
                                self.selectRange = rangeManager
                                row.value = rangeManager.getSelectRangesPeopleCount()
                                row.reload()
                                self.form.last?.reload()
                            }
                            self.saveDraft()
                        }
                        let nav = SW_NavViewController(rootViewController: selectVc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                        
                    }
                    
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        guard let self = self else { return }
                        
                        if self.rangeManager != nil {
                            row.isSelect = true
                            self.selectRange = self.rangeManager
                            self.saveDraft()
                            self.form.last?.reload()
                        } else {
                            if let selectRange = self.selectRange, self.commonContactRange.contains(selectRange) == true {/// 选中了常用范围
                                self.selectRange = nil
                                self.form.last?.reload()
                            }
                            
                            let selectVc = SW_SelectInformRangeViewController(self.type ?? .group, rangeManager: nil)
                            selectVc.selectSuccesBlock = { [weak self] (rangeManager, informType, isAddCommonRange) in
                                guard let self = self else { return }
                                if isAddCommonRange {
                                    self.commonContactRange = SW_RangeManager.getCommonContactRange(informType: self.type ?? .group)
                                    self.selectRange = self.commonContactRange.last
                                    self.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                        self?.createTableView()
                                    })
                                } else {
                                    self.rangeManager = rangeManager
                                    self.selectRange = rangeManager
                                    row.value = rangeManager.getSelectRangesPeopleCount()
                                    row.reload()
                                }
                                self.saveDraft()
                            }
                            let nav = SW_NavViewController(rootViewController: selectVc)
                            nav.modalPresentationStyle = .fullScreen
                            self.present(nav, animated: true, completion: nil)
                        }
                        
                    }).cellUpdate({ [weak self] (cell, row) in
                        row.isSelect = self?.rangeManager == self?.selectRange && self?.rangeManager != nil
                    })
        
        } else {
            form.last!
                
            <<< SW_CommenLabelRow("send type1") {
                $0.rawTitle = NSLocalizedString("发送类型", comment: "")
                $0.value = ""
                $0.cell.placeholder = "点击选择类型"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    
                    let dataSource = SW_UserCenter.shared.user!.auth.messageAuth[0].authDetails.map({ return $0.rawTitle })
                    
                    BRStringPickerView.showStringPicker(withTitle: nil, on: MYWINDOW, dataSource: dataSource, defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
                        if let selectValue = selectValue as? String {
                            self?.type = InformType(selectValue)
                            self?.saveDraft()
                        }
                        })
                })
        }
                    
        if commonContactRange.count > 0 {
            form +++
                Eureka.Section() { section in
                    var header = HeaderFooterView<SectionHeaderView>(.class)
                    header.height = {34}
                    header.onSetupView = { view, _ in
                        view.backgroundColor = UIColor.white
                        view.titleView.font = Font(13)
                        view.titleView.textColor = UIColor.v2Color.lightGray
                        view.title = "常用发送范围"
                    }
                    section.header = header
            }
            
            for index in 0..<commonContactRange.count {
                let commonRange = commonContactRange[index]
                form.last!
                    <<< SW_CommonRangesRow("CommonContactRange\(index)") {
                        $0.rowTitle = commonRange.name
                        $0.value = commonRange.getSelectRangesPeopleCount()
                        $0.isSelect = commonRange == selectRange
                        $0.deleteBlock = { [weak self] in
                            guard let self = self else {  return }
                            
                            alertControllerShow(title: "你确定删除此常用发送范围吗？", message: nil, rightTitle: "确 定", rightBlock: { (_, _) in
                                SW_RangeManager.deleteCommonContactRange(informType: self.type ?? .group, rangeManager: commonRange)
                                self.commonContactRange = SW_RangeManager.getCommonContactRange(informType: self.type ?? .group)
                                if commonRange == self.selectRange {
                                    self.selectRange = nil
                                    self.saveDraft()
                                }
                                self.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                    self?.createTableView()
                                })
                            }, leftTitle: "取 消", leftBlock: nil)
                            
                        }
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
//                            if row.isSelect == true {
//                                self?.selectRange = self?.rangeManager
//                            } else {
                                self?.selectRange = commonRange
                                self?.saveDraft()
//                            }
                            self?.form.rowBy(tag: "send range")?.reload()
                            self?.form.last?.reload()
                        }).cellUpdate({ [weak self] (cell, row) in
                            row.isSelect = commonRange == self?.selectRange
                    })
            }
        }
//        if !becomeFirst {
            tableView.reloadData()
//        }
    }
    
    
    @objc func cancelBtnAction(_ sender: UIBarButtonItem) {
        alertControllerShow(title: "将此次编辑保留？", message: nil, rightTitle: "保留", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "不保留", leftBlock: { (controller, action) in
            /// 清空保存的草稿数据
            self.removeDraft()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    /// 保存草稿
    private func saveDraft() {
        cache?.setObject(informTitle as NSCoding, forKey: "informTitle", with: nil)
        cache?.setObject(content as NSCoding, forKey: "content", with: nil)
        cache?.setObject(fileBase64 as NSCoding, forKey: "fileBase64", with: nil)
        if let type = type {/// 选择的type才会有范围
            cache?.setObject(type.rawValue as NSCoding, forKey: "type", with: nil)
            
            if let selectRange = selectRange, let index = commonContactRange.firstIndex(of: selectRange) {/// 有选择范围才存
                cache?.setObject(index as NSCoding, forKey: "selectRangeIndex")
            } else {
                cache?.removeObject(forKey: "selectRangeIndex")/// 清空选中的index
            }
            
            if let rangeManager = rangeManager {/// 有临时范围则保存临时范围
                cache?.setObject(rangeManager as NSCoding, forKey: "rangeManager")
            } else {
                cache?.removeObject(forKey: "rangeManager")
            }
        }
    }
    
    /// 清空草稿
    private func removeDraft() {
        cache?.removeAllObjects()
    }
    
    /// 恢复草稿数据
    private func restoreDraft() {
        /// 判断权限是否包含草稿选择的公告类型、不包含时直接清空草稿
        if let aType = cache?.object(forKey: "type") as? Int, let informType = InformType(rawValue: aType) {
            /// 包含权限
            if SW_UserCenter.shared.user!.auth.messageAuth[0].authDetails.contains(informType) {
                /// 恢复类型和选择的范围
                type = informType
                commonContactRange = SW_RangeManager.getCommonContactRange(informType: informType)
                if let rangeManager = cache?.object(forKey: "rangeManager") as? SW_RangeManager {
                    self.rangeManager = rangeManager
                }
                if let selectRangeIndex = cache?.object(forKey: "selectRangeIndex") as? Int, commonContactRange.count > selectRangeIndex {
                    self.selectRange = commonContactRange[selectRangeIndex]
                } else {
                    self.selectRange = self.rangeManager
                }
            } else {
                /// 不包含权限
                removeDraft()
                return
            }
        }
        /// 可能输入了内容，没有选择范围、恢复内容
        informTitle = cache?.object(forKey: "informTitle") as? String ?? ""
        content = cache?.object(forKey: "content") as? String ?? ""
        fileBase64 = cache?.object(forKey: "fileBase64") as? String ?? ""
    }
    
    @objc func postBtnAction(_ sender: UIBarButtonItem) {
        guard !isRequesting else { return }
        
        guard !informTitle.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else {
            showAlertMessage(InternationStr("请输入公告主标题"), view)
            (form.rowBy(tag: "informTitle") as? SW_CommenTextViewRow)?.showErrorLine()
            (form.rowBy(tag: "content") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        guard !content.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else {
            showAlertMessage(InternationStr("请输入公告内容"), view)
            (form.rowBy(tag: "content") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        guard let type = type else {
            showAlertMessage(InternationStr("请选择公告类型"), view)
            return
        }
        guard let rangeManager = selectRange, rangeManager.getSelectRangesPeopleCount() != "0人" else {
            showAlertMessage(InternationStr("请选择发送范围"), view)
            return
        }
        isRequesting = true
        let (rangeType, IdStr) = rangeManager.getSelectRangesTypeAndIdStr()
        QMUITips.showLoading("正在发布", in: self.view)
        SW_WorkingService.sendInform(SW_UserCenter.shared.user!.id, msgTypeId: type.rawValue, type: rangeType.rawValue, title: informTitle, content: content, fileBase64: fileBase64, fileName: "1.jpg", sendList: IdStr).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                //                if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_InformManageViewController} ) {
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadPostInform, object: nil, userInfo: ["informType": type])
                self.removeDraft()
                showAlertMessage(InternationStr("发布成功"), self.view)
                //                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[index])!, animated: true)
                //                } else {
                self.navigationController?.popViewController(animated: true)
                //                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    }
    
}


// MARK: - TableViewDelegate
extension SW_SendInformTwoViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}

