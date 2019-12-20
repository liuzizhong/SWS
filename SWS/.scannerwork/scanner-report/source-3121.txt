//
//  SW_SelectInformRangeViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

//最后的bool值是判断是否添加了常用范围  如果添加了则返回true  通知界面刷新
typealias SelectRangeSucces = (SW_RangeManager, InformType, Bool)->Void

class SW_SelectInformRangeViewController: UIViewController {
    
    var selectAllBtn = SW_SelectAllButton(type: .custom)
    
    var bottomView: SW_RangeBottomView = {
        let bottom = Bundle.main.loadNibNamed(String(describing: SW_RangeBottomView.self), owner: nil, options: nil)?.first as! SW_RangeBottomView
        return bottom
    }()
    
    var selectSuccesBlock: SelectRangeSucces?
    
//    公告类型
    fileprivate var informType = InformType.group {
        didSet {
            switch informType {
            case .group:
                canShowPageType = [.region, .business, .department, .staff]
            case .business:
                canShowPageType = [.department, .staff]
            case .department:
                canShowPageType = [.staff]
            }
        }
    }

    // 当前显示页面的列表类型          默认是集团公告  显示所有内容
    private var pageType = RangeType.region
    
    private var rangeManager = SW_RangeManager()
    
    private var currentPageVc: SW_RangeListViewController!
    //用来创建子控制器
    private var canShowPageType: [RangeType] = [.region, .business, .department, .staff]
    
    init(_ informType: InformType, rangeManager: SW_RangeManager?) {
        super.init(nibName: nil, bundle: nil)
        self.informType = informType
        self.pageType = getPageType()
        if let rangeManager = rangeManager {
            self.rangeManager = rangeManager.copy() as! SW_RangeManager//后期有编辑
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = InternationStr("发送范围")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: InternationStr("取消"), style: .plain, target: self, action: #selector(cancelBtnClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(sureAction(_:)))//
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sureBtn)
        
        view.addSubview(selectAllBtn)
        selectAllBtn.addTarget(self, action: #selector(selectAllBtnAction(_:)), for: .touchUpInside)
        selectAllBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(54)
        }
        
        view.addSubview(bottomView)
        let selectRange = rangeManager.getSelectRanges(type: pageType)
        bottomView.checkBtnHiddenState(informType: informType, currentPage: pageType, selectRange: selectRange)
        checkSureBtnState(selectRange: selectRange)
        bottomView.btnClickBlock = { [weak self] (btnType) in
            switch btnType {
            case .last:
                self?.lastAction()
            case .sure:
//                self?.sureAction(UIButton())
                break
            case .next:
                self?.nextAction()
            }
        }
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(-TABBAR_BOTTOM_INTERVAL)
            make.height.equalTo(54)
        }
        
        //判断处理-----  informtype 部门跟单位 需要初始化时传入 自己所在的idsString
        var selectId = ""
        switch informType {
        case .business:
            selectId = "\(SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId)"
        case .department:
            selectId = "\(SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId)_\(SW_UserCenter.shared.user!.staffWorkDossier.departmentId)"
        default:
            break
        }
        //添加子控制器
        for type in canShowPageType {
            let childVc = SW_RangeListViewController(type, selectIds: selectId, manager: rangeManager, listType: .inform, groupNum: nil)
            addChild(childVc)
            childVc.rangeChangeBlock = { [weak self] in
                self?.checkBtnState()
            }
            if type == pageType {
                currentPageVc = childVc
                currentPageVc.getListAndReload()
                view.addSubview(childVc.view)
                childVc.view.snp.makeConstraints({ (make) in
                    make.top.equalTo(selectAllBtn.snp.bottom)
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(bottomView.snp.top)
                })
                childVc.didMove(toParent: self)
            }
        }
        
    }
    
    //点击上一步的事件切换子控制器
    private func lastAction() {
        if let index = canShowPageType.firstIndex(of: pageType) {
            changeChildVc(toIndex: index - 1, goNext: false)
        }
    }
    
    //点击确定选人按钮的事件
    @objc private func sureAction(_ sender: QMUIButton) {
        ///----------
        alertControllerShow(title: "将所选项保存到常用发送范围?", message: nil, rightTitle: "保 存", rightBlock: { (controller, action) in
            let nameAlert = UIAlertController.init(title: InternationStr("请输入常用发送范围名称"), message: nil, preferredStyle: .alert)
            var field: UITextField!
            nameAlert.addTextField { (textfield) in
                field = textfield
                textfield.placeholder = InternationStr("名称")
                textfield.keyboardType = .default
                textfield.clearButtonMode = .whileEditing
                textfield.borderStyle = .roundedRect
            }
            let sure = UIAlertAction(title: "确认", style: .default, handler: { [weak self] action in
                if let text = field.text , !text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                    guard let sSelf = self else { return }
                    sSelf.rangeManager.name = text
                    SW_RangeManager.saveCommonContactRange(informType: sSelf.informType, rangeManager: sSelf.rangeManager)
                    sSelf.selectSuccesBlock?(sSelf.rangeManager, sSelf.informType, true)
                    sSelf.dismiss(animated: true, completion: nil)
                } else {
                    showAlertMessage(InternationStr("发送范围名称不可以为空"), MYWINDOW)
                }
            })
            nameAlert.addAction(sure)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            nameAlert.addAction(cancel)
            self.present(nameAlert, animated: true, completion: nil)
            nameAlert.clearTextFieldBorder()
        }, leftTitle: "发 送") { (controller, action) in
            //回调给上级页面
            self.selectSuccesBlock?(self.rangeManager, self.informType, false)
            self.dismiss(animated: true, completion: nil)
            }
    }
    
    //点击下一步的事件切换子控制器
    private func nextAction() {
        if let index = canShowPageType.firstIndex(of: pageType) {
            changeChildVc(toIndex: index + 1, goNext: true)
        }
    }
    
    @objc fileprivate func cancelBtnClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func selectAllBtnAction(_ sender: UIButton) {
        currentPageVc.selectAllBtnClick(isSelect: !sender.isSelected)
    }
    
    fileprivate func checkBtnState() {
        // 要让当前选择的控制器去判断是否选择全部了。
        selectAllBtn.isSelected = currentPageVc.isSelectAll()
        let selectRange = rangeManager.getSelectRanges(type: pageType)
        bottomView.checkBtnHiddenState(informType: informType, currentPage: pageType, selectRange: selectRange)
        checkSureBtnState(selectRange: selectRange)
    }
    
    private func checkSureBtnState(selectRange: [SW_RangeModel]) {
        navigationItem.rightBarButtonItem?.isEnabled = selectRange.count != 0
        let count = selectRange.reduce(0) { (rusult, model) -> Int in
            if model.type == .staff {
                return rusult + 1
            } else {
                return rusult + model.staffCount
            }
        }
        navigationItem.rightBarButtonItem?.title = InternationStr("确定(\(count)人)")
//        sureBtn.setTitle(InternationStr("确定(\(count)人)"), for: UIControl.State())//TODO: 该处计算人数部分可以去除  也可以保留
    }
    
    /// 切换子视图控制器
    ///
    /// - Parameters:
    ///   - toIndex: 切换的控制器下标
    ///   - goNext: 是否是下一步
    fileprivate func changeChildVc(toIndex: Int, goNext: Bool) {
        guard toIndex >= 0 && toIndex < canShowPageType.count else {
            showAlertMessage(InternationStr("切换越界啦、找程序猿锅锅看看吧~！"), view)
            return
        }
        
        let toVc = children[toIndex] as! SW_RangeListViewController
        if goNext {//如果进入下级  需要传入  idStr  并通知刷新数据
            toVc.idStr = rangeManager.getSelectRangesIdStr(type: pageType)//根据当前页面选中的列表项组成idstr
            toVc.getListAndReload()
        } else {//如果返回上级   下级选择的项不保留 全部清空
            rangeManager.removeSelectRanges(type: pageType)
            currentPageVc.clearCurrentList()
        }
        
        currentPageVc.view.removeFromSuperview()
        view.addSubview(toVc.view)
        toVc.view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.selectAllBtn.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        })
        toVc.didMove(toParent: self)
        currentPageVc = toVc
        pageType = canShowPageType[toIndex]
        checkBtnState()

        
        
//        transition(from: currentVc, to: lastVc, duration: 0, options: UIView.AnimationOptions(), animations: nil) { (finish) in
//            if finish {
//                lastVc.view.snp.makeConstraints({ (make) in
//                    make.top.equalTo(self.selectAllBtn.snp.bottom)
//                    make.leading.trailing.equalToSuperview()
//                    make.bottom.equalTo(self.bottomView.snp.top)
//                })
//                lastVc.didMove(toParentViewController: self)
//            }
//        }
    }
    
    fileprivate func getPageType() -> RangeType {
        switch informType {
        case .group:
            return .region
        case .business:
            return .department
        case .department:
            return .staff
        }
    }

    
    deinit {
        PrintLog("deinit----")
    }
}
