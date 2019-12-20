//
//  SW_PeopleRangeViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/15.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

typealias SelectPeopleSucces = (SW_RangeManager)->Void

class SW_PeopleRangeViewController: UIViewController {
    
    var selectAllBtn = SW_SelectAllButton(type: .custom)
    
    var bottomView: SW_RangeBottomView = {
        let bottom = Bundle.main.loadNibNamed(String(describing: SW_RangeBottomView.self), owner: nil, options: nil)?.first as! SW_RangeBottomView
        return bottom
    }()
    
    var selectSuccesBlock: SelectPeopleSucces?//要改
    
    var rightItemBlock: RightBarItemStateChange?
    
    //    公告类型
    fileprivate var rangeType = AddressBookPage.main
    
    // 当前显示页面的列表类型          默认是集团公告  显示所有内容
    fileprivate var pageType = RangeType.region
    
    //存放当前模块选择的人范围  默认都是没有选人
    fileprivate var rangeManager = SW_RangeManager()
    
    //编辑群成员时需要groupnum 服务端会去除当前群成员
    var groupNum: String?
    
    /// 添加接收人时默认选择的员工
    var selectMember = [SW_RangeModel]() {
        didSet {
            rangeManager.selectStaffs = selectMember
        }
    }
    
    fileprivate var currentPageVc: SW_RangeListViewController!
    //用来创建子控制器
    fileprivate var canShowPageType: [RangeType] = [.region, .business, .department, .staff]
    
    init(_ rangeType: AddressBookPage) {
        super.init(nibName: nil, bundle: nil)
        self.rangeType = rangeType
        switch rangeType {
        case .main:
            canShowPageType = [.region, .business, .department, .staff]
        case .region:
            canShowPageType = [.business, .department, .staff]
        case .business:
            canShowPageType = [.department, .staff]
        case .department:
            canShowPageType = [.staff]
        }
        self.pageType = canShowPageType[0]
        
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
    
    fileprivate func setup() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(selectAllBtn)
        selectAllBtn.addTarget(self, action: #selector(selectAllBtnAction(_:)), for: .touchUpInside)
        selectAllBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(49)
        }
        if rangeType != .department {
            view.addSubview(bottomView)
            bottomView.checkBtnHiddenState(rangeType: rangeType, currentPage: pageType, selectRange: rangeManager.getSelectRanges(type: pageType))
            bottomView.btnClickBlock = { [weak self] (btnType) in
                switch btnType {
                case .last:
                    self?.lastAction()
                case .sure:
                    self?.sureAction()
                case .next:
                    self?.nextAction()
                }
            }
            bottomView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(-TABBAR_BOTTOM_INTERVAL)
                make.height.equalTo(53)
            }
        }
        
        //判断处理-----  rangeType 部门跟单位 需要初始化时传入 自己所在的idsString
        var selectId = ""
        switch rangeType {
        case .region:
            selectId = "\(SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId)"
        case .business:
            selectId = "\(SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId)"
        case .department:
            selectId = "\(SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId)_\(SW_UserCenter.shared.user!.staffWorkDossier.departmentId)"
        default:
            break
        }
        //添加子控制器
        for type in canShowPageType {
            let childVc = SW_RangeListViewController(type, selectIds: selectId, manager: rangeManager, listType: .group, groupNum: groupNum)
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
                    if rangeType == .department {
                        make.bottom.equalToSuperview()
                    } else {
                        make.bottom.equalTo(bottomView.snp.top)
                    }
                })
                childVc.didMove(toParent: self)
            }
        }
        
    }
    
    fileprivate func lastAction() {
        if let index = canShowPageType.index(of: pageType) {
            changeChildVc(toIndex: index - 1, goNext: false)
        }
    }
    
    fileprivate func sureAction() {
        //判断是否选择了又人。必须要选了人才能  确认
        guard rangeManager.selectStaffs.count > 0 else {
            showAlertMessage("请选择人", self.view)
            return
        }
    }
    
    fileprivate func nextAction() {
        if let index = canShowPageType.index(of: pageType) {
            changeChildVc(toIndex: index + 1, goNext: true)
        }
    }
    
    @objc fileprivate func selectAllBtnAction(_ sender: UIButton) {
        currentPageVc.selectAllBtnClick(isSelect: !sender.isSelected)
    }
    
    fileprivate func checkBtnState() {
        // 要让当前选择的控制器去判断是否选择全部了。
        selectAllBtn.isSelected = currentPageVc.isSelectAll()
        selectSuccesBlock?(rangeManager)
        if pageType == .staff {
            let selectRange = rangeManager.getSelectRanges(type: pageType)
            let count = selectRange.reduce(0) { (rusult, model) -> Int in
                if model.type == .staff {
                    return rusult + 1
                } else {
                    return rusult + model.staffCount
                }
            }
            rightItemBlock?(false,selectRange.count != 0,InternationStr("确定(\(count)人)"))
            if rangeType != .department {
                bottomView.checkBtnHiddenState(rangeType: rangeType, currentPage: pageType, selectRange: rangeManager.getSelectRanges(type: pageType))
            }
        } else {
            rightItemBlock?(true,false,"确定")
            bottomView.checkBtnHiddenState(rangeType: rangeType, currentPage: pageType, selectRange: rangeManager.getSelectRanges(type: pageType))
        }
    }
    
    
    func reSetController() {
        rangeManager.clearAllSelect()
        changeChildVc(toIndex: 0, goNext: false)
        rangeManager.selectStaffs = selectMember
        currentPageVc.tableView.reloadData()
    }
    
    func reloadCurrentVc() {
        currentPageVc.getListAndReload()
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
            if rangeType == .department {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(bottomView.snp.top)
            }
//            make.bottom.equalTo(self.bottomView.snp.top)
        })
        toVc.didMove(toParent: self)
        currentPageVc = toVc
        pageType = canShowPageType[toIndex]
        checkBtnState()
    }
    
    
    
    deinit {
        PrintLog("deinit----")
    }
}
