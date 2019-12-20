//
//  SW_SelectPeopleRangeViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/15.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import PagingMenuController


enum SelectPeopleType {
    case creatGroup
    case addGroupMember
    case addPushMember
    case addTopConversation
}

typealias RightBarItemStateChange = (Bool,Bool,String)->Void

/// 旧的选人控制器，
class SW_SelectPeopleRangeViewController: UIViewController {

    private var navTitle = ""
    private var groupNum: String?
    private var type = SelectPeopleType.creatGroup
    private var isRequesting = false
    
    private lazy var rightBarItem: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(sureAction(_:)))
        return btn
    }()
    
    var rangeManager: SW_RangeManager!
    
    var selectMember = [SW_RangeModel]()
    
    init(_ groupNum: String?, navTitle: String = "创建工作群", type: SelectPeopleType) {
        super.init(nibName: nil, bundle: nil)
        self.groupNum = groupNum
        self.navTitle = navTitle
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setup() {
        view.backgroundColor = UIColor.white
        navigationItem.title = InternationStr(navTitle)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: InternationStr("取消"), style: .plain, target: self, action: #selector(cancelAction(_:)))
        
        let selectSuccesBlock: SelectPeopleSucces = { [weak self] (rangeManager) in
            self?.rangeManager = rangeManager
        }
        let rightItemBlock: RightBarItemStateChange = { [weak self] (isHidden,isEnable,title) in
            if isHidden {
                self?.navigationItem.rightBarButtonItem = nil
            } else {
                self?.navigationItem.rightBarButtonItem = self?.rightBarItem
                self?.rightBarItem.isEnabled = isEnable
                self?.rightBarItem.title = title
            }
        }
        
        let options = SelectPeopleRangeMenuOptions(groupNum, succesBlock: selectSuccesBlock, selectMember: selectMember, rightItemChange: rightItemBlock)
        let pagingMenuController = PagingMenuController(options: options)
        
        pagingMenuController.onMove = { state in
            switch state {
//            case let .willMoveController(menuController, previousMenuController):
//                print("--- 页面将要切换 ---")
//                print("老页面：\(previousMenuController)")
//                print("新页面：\(menuController)")
            case let .didMoveController(menuController, previousMenuController):
                (previousMenuController as! SW_PeopleRangeViewController).reSetController()
                (menuController as! SW_PeopleRangeViewController).reloadCurrentVc()
            default:
                break
            }
        }
        
        self.addChild(pagingMenuController)
        self.view.addSubview(pagingMenuController.view)
        pagingMenuController.view.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        pagingMenuController.didMove(toParent: self)
        pagingMenuController.move(toPage: 2, animated: false)
    }
    
    @objc func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func dealSelectPeople(_ rangeManager: SW_RangeManager) {
        switch type {
        case .addPushMember:
            if rangeManager.selectStaffs.count > 8 {
                showAlertMessage("最多选择8个接收人", MYWINDOW)
                return
            }
            NotificationCenter.default.post(name: Notification.Name.Ex.HadSelectPushMember, object: nil, userInfo: ["selectStaffs":rangeManager.selectStaffs])
            dismiss(animated: true, completion: nil)
        case .addGroupMember:
            if let groupNum = groupNum {//有群num代表添加群成员
                guard !isRequesting else { return }
                QMUITips.showLoading("正在添加", in: self.view)
                isRequesting = true
                SW_GroupService.addGroupMember(groupNum, staffIds: rangeManager.getSelectPeopleIdStr()).response({ (json, isCache, error) in
                    if let _ = json as? JSON, error == nil {
                        showAlertMessage("添加群成员成功", self.view)
                        NotificationCenter.default.post(name: Notification.Name.Ex.GroupMembersHadChange, object: nil, userInfo: ["isAdd": true,"count": rangeManager.selectStaffs.count])
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                    QMUITips.hideAllTips(in: self.view)
                    self.isRequesting = false
                })
            }
        case .creatGroup:
            ///创建群
            guard rangeManager.selectStaffs.count <= 500 else {
                showAlertMessage("最多选择500位群成员", MYWINDOW)
                return
            }
            self.navigationController?.pushViewController(SW_CreatGroupViewController.ctreatVc(rangeManager), animated: true)
        case .addTopConversation:
            ///添加置顶联系人
//            rangeManagerprint
//            PrintLog(rangeManager)
            rangeManager.selectStaffs.forEach { (model) in
                if !model.huanxinUser.isEmpty {
                    SW_TopConversationManager.addTopConversation(model.huanxinUser,chatType: EMConversationTypeChat)
                }
            }
            NotificationCenter.default.post(name: Notification.Name.Ex.TopConversationsHadChange, object: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func sureAction(_ sender: UIBarButtonItem) {
        //判断是否选择了又人。必须要选了人才能  确认
        dealSelectPeople(rangeManager)
    }
    
    deinit {
        PrintLog("deinit--")
    }
}



private struct SelectPeopleRangeMenuOptions: PagingMenuControllerCustomizable {
    
    let pv1 = SW_PeopleRangeViewController(.main)
    let pv2 = SW_PeopleRangeViewController(.region)
    let pv3 = SW_PeopleRangeViewController(.business)
    let pv4 = SW_PeopleRangeViewController(.department)
    
    init(_ groupNum: String?, succesBlock: SelectPeopleSucces?, selectMember: [SW_RangeModel], rightItemChange: RightBarItemStateChange?) {
        pagingControllers.forEach({
            ($0 as! SW_PeopleRangeViewController).groupNum = groupNum
            ($0 as! SW_PeopleRangeViewController).selectSuccesBlock = succesBlock
            ($0 as! SW_PeopleRangeViewController).selectMember = selectMember
            ($0 as! SW_PeopleRangeViewController).rightItemBlock = rightItemChange
        })
    }
    
    fileprivate var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    
    fileprivate var pagingControllers: [UIViewController] {
        return [pv1, pv2, pv3, pv4]
    }
    
    var lazyLoadingPage: LazyLoadingPage {
        return .one
    }
    
    fileprivate struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .segmentedControl
        }
        
        var height: CGFloat {
            return 40
        }
        
        var segmentedControlWidth: CGFloat? {
            return 80
        }
        
        var focusMode: MenuFocusMode {
            return .underline(height: 2, color: UIColor.mainColor.blue, horizontalPadding: 20, verticalPadding: 0, flexible: true)
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItem1(), MenuItem2(), MenuItem3(), MenuItem4()]
        }
    }
    
    fileprivate struct MenuItem1: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "全部分区", color: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), selectedColor: UIColor.mainColor.blue, font: Font(14), selectedFont: Font(15)))
        }
    }
    
    fileprivate struct MenuItem2: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "我的分区", color: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), selectedColor: UIColor.mainColor.blue, font: Font(14), selectedFont: Font(15)))
        }
    }
    
    fileprivate struct MenuItem3: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "我的单位", color: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), selectedColor: UIColor.mainColor.blue, font: Font(14), selectedFont: Font(15)))
        }
    }
    
    fileprivate struct MenuItem4: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            return .text(title: MenuItemText(text: "我的部门", color: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), selectedColor: UIColor.mainColor.blue, font: Font(14), selectedFont: Font(15)))
        }
    }
}
