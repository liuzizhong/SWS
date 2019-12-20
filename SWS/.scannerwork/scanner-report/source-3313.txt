//
//  SW_OrderDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/1.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_OrderDetailViewController: UIViewController {
    private var repairOrderId = ""
    
    private var isRequesting = false
    
    private var isInvalid = false
    
    private var recordData: SW_RepairOrderRecordDetailModel!
    
    private var afterSaleGroupList = [AfterSaleGroup]()
    
    private var pageTitles = ["维修项目","维修配件","精品信息","其他费用","活动套餐","优惠券","建议项目"]
    private let orderItemFormVc = SW_OrderItemFormViewController()
    
    private var pageControllers: [UIViewController]!
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.titleFont = Font(16)
        layout.titleMargin = min((SCREEN_WIDTH - 294) / 4, 40)
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let H: CGFloat = SCREEN_HEIGHT - NAV_TOTAL_HEIGHT
        return CGRect(x: 0, y: 0, width: view.bounds.width, height: H)
    }
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: managerReact(), viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let self = self else { return UIView() }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 280+self.recordData.customerNameHeight))
            let header = Bundle.main.loadNibNamed(String(describing: SW_OrderDetailInfoHeader.self), owner: nil, options: nil)?.first as! SW_OrderDetailInfoHeader
            header.orderModel = self.recordData
            /// 禁止后上面可以滚动
            view.isUserInteractionEnabled = false
            view.addSubview(header)
            header.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            return view
        })
        /* 设置代理 监听滚动 */
        advancedManager.delegate = self
        /* 点击切换滚动过程动画 */
        advancedManager.isClickScrollAnimation = true
        return advancedManager
    }()
    
    private var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.setTitle("派工", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(dispatchAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    class func creatVc(_ repairOrderId: String, isInvalid: Bool) -> SW_OrderDetailViewController {
        let vc = SW_OrderDetailViewController()
        vc.repairOrderId = repairOrderId//"ff8080816bda0c6f016bda6c3f050021"
        vc.isInvalid = isInvalid
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        pageControllers = [orderItemFormVc,SW_RepairOrderItemFormViewController(),SW_RepairOrderItemFormViewController(),SW_RepairOrderItemFormViewController(),SW_RepairOrderItemFormViewController(),SW_RepairOrderItemFormViewController(),SW_RepairOrderItemFormViewController()]
        pageControllers.forEach({ $0.view.backgroundColor = .white })
        requestDetailDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setup() {
        navigationItem.title = recordData.repairOrderNum
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "AddressBook_more"), style: .plain, target: self, action: #selector(moreAction(_:)))
        /// 作废、待质检、质检已通过的全单不可选择、
        let notDisPatch = isInvalid || recordData.qualityState == .waitQuality || recordData.qualityState == .qualified
        orderItemFormVc.isInvalid = notDisPatch
        
        view.addSubview(advancedManager)
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM_INTERVAL + 54)
        }
        bottomView.blueBtn.snp.remakeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.equalTo(5)
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
        orderItemFormVc.items = recordData.repairOrderItemList
        (pageControllers[1] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairOrderAccessoriesList
        (pageControllers[2] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairOrderBoutiquesList
        (pageControllers[3] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairOrderOtherInfoList
        (pageControllers[4] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairPackageItemList
        (pageControllers[5] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairOrderCouponsList
        (pageControllers[6] as? SW_RepairOrderItemFormViewController)?.items = recordData.suggestItemList
        bottomView.isHidden = orderItemFormVc.canSelectItems.count == 0
    }
    
    @objc private func dispatchAction(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        guard !isRequesting else { return }
        let selectItems = orderItemFormVc.selectItems
        if selectItems.count == 0 {
            showAlertMessage("请选择维修项目", MYWINDOW)
            return
        }
        if afterSaleGroupList.count > 0 {
            showAfterSaleGroupPicker(selectItems)
        } else {
            isRequesting = true
            SW_AfterSaleService.getAfterSaleGroupList(recordData.bUnitId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.afterSaleGroupList = json["list"].arrayValue.map({ return AfterSaleGroup($0) })
                    self.showAfterSaleGroupPicker(selectItems)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
                self.isRequesting = false
            })
        }
    }
    
    // 弹出联动选择框
    private func showAfterSaleGroupPicker(_ items: [SW_RepairOrderItemModel]) {
        guard afterSaleGroupList.count > 0 else { return }
        
        BRAddressPickerView.showAddressPicker(withShowType: BRAddressPickerMode.init(rawValue: 2)!, title: "派工", dataSource: afterSaleGroupList.map({ return ["name": $0.name,"code":$0.id,"citylist":$0.subList.map({ return ["name":$0] })] }), defaultSelected: ["",""], isAutoSelect: false, themeColor: UIColor.v2Color.blue, resultBlock: { [weak self] (province, city, area) in
            guard let self = self else { return }
            self.isRequesting = true
            QMUITips.showLoading("正在派工", in: self.view)
            SW_AfterSaleService.dispatchRepairItem(self.repairOrderId, repairItemList: items, groupName: province?.name ?? "", groupId: province?.code ?? "", areaNum: city?.name ?? "").response({ (json, isCache, error) in
                if let _ = json as? JSON, error == nil {
                    showAlertMessage("派工成功", MYWINDOW)
                    self.requestDetailDatas(setup: false)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                QMUITips.hideAllTips(in: self.view)
                self.isRequesting = false
            })
            
        }, cancel: nil)
    }
    
    @objc private func moreAction(_ sender: UIBarButtonItem) {
        let sheetW = isIPad ? 270 : SCREEN_WIDTH
        let actionSheet = QMUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // 样式设置
        var buttonAttributes = actionSheet.sheetButtonAttributes
        buttonAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.blue
        buttonAttributes?[NSAttributedString.Key.font] = Font(16)
        
        /// 添加action
        let phoneAction = QMUIAlertAction(title: "电话", style: .default) { (alertController, action) in
            if !self.recordData.customerPhoneNum.isEmpty {
                UIApplication.shared.open(scheme: "tel://\(self.recordData.customerPhoneNum)")//
            }
        }
        phoneAction.button.setImage(UIImage(named: "personalcenter_icon_phone"), for: UIControl.State())
        
        phoneAction.button.spacingBetweenImageAndTitle = sheetW - 100
        phoneAction.button.imagePosition = .right
        actionSheet.addAction(phoneAction)
        
        let msgAction = QMUIAlertAction(title: "消息", style: .default) { (alertController, action) in
            if !self.recordData.customerPhoneNum.isEmpty {
                UIApplication.shared.open(scheme: "sms://\(self.recordData.customerPhoneNum)")//
            }
        }
        msgAction.button.setImage(UIImage(named: "personalcenter_icon_messages"), for: UIControl.State())
        msgAction.button.spacingBetweenImageAndTitle = sheetW - 100
        msgAction.button.imagePosition = .right
        actionSheet.addAction(msgAction)
        
        /// 送修人不一样时显示
        if !recordData.senderPhone.isEmpty, recordData.senderPhone != recordData.customerPhoneNum {
        
            let senderPhoneAction = QMUIAlertAction(title: "电话(送修人)", style: .default) { (alertController, action) in
                if !self.recordData.customerPhoneNum.isEmpty {
                    UIApplication.shared.open(scheme: "tel://\(self.recordData.customerPhoneNum)")//
                }
            }
            senderPhoneAction.button.setImage(UIImage(named: "personalcenter_icon_phone"), for: UIControl.State())
            
            senderPhoneAction.button.spacingBetweenImageAndTitle = sheetW - 160
            senderPhoneAction.button.imagePosition = .right
            actionSheet.addAction(senderPhoneAction)
            
            let senderMsgAction = QMUIAlertAction(title: "消息(送修人)", style: .default) { (alertController, action) in
                if !self.recordData.customerPhoneNum.isEmpty {
                    UIApplication.shared.open(scheme: "sms://\(self.recordData.customerPhoneNum)")//
                }
            }
            senderMsgAction.button.setImage(UIImage(named: "personalcenter_icon_messages"), for: UIControl.State())
            senderMsgAction.button.spacingBetweenImageAndTitle = sheetW - 160
            senderMsgAction.button.imagePosition = .right
            actionSheet.addAction(senderMsgAction)
            
            senderPhoneAction.buttonAttributes = buttonAttributes
            senderMsgAction.buttonAttributes = buttonAttributes
        }
    
        
        if !isIPad {
            actionSheet.addCancelAction()
        }
        
        actionSheet.sheetButtonAttributes = buttonAttributes
        
        msgAction.buttonAttributes = buttonAttributes
        phoneAction.buttonAttributes = buttonAttributes
        
        var buttonDisabledAttributes = actionSheet.sheetButtonDisabledAttributes
        buttonDisabledAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.disable
        buttonDisabledAttributes?[NSAttributedString.Key.font] = Font(16)
        actionSheet.sheetButtonDisabledAttributes = buttonDisabledAttributes
        
        var cancelAttributs = actionSheet.sheetCancelButtonAttributes
        cancelAttributs?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.blue
        cancelAttributs?[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 16)
        actionSheet.sheetCancelButtonAttributes = cancelAttributs
        
        actionSheet.showWith(animated: true)
    }
    
    private func requestDetailDatas(setup: Bool = true) {
        SW_AfterSaleService.getRepairOrderDetail(repairOrderId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordData = SW_RepairOrderRecordDetailModel(json)
                if setup {
                    self.setup()
                } else {
                    self.orderItemFormVc.items = self.recordData.repairOrderItemList
                   
                    self.bottomView.isHidden = self.orderItemFormVc.canSelectItems.count == 0
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
}

extension SW_OrderDetailViewController: LTAdvancedScrollViewDelegate {
}

class AfterSaleGroup: NSObject {
    
    var name = ""
    var id = ""
    /// areaNum
    var subList = [String]()
    
    init(_ json: JSON) {
        super.init()
        name = json["afterSaleGroupName"].stringValue
        id  = json["afterSaleGroupId"].stringValue
        subList = json["repairAreaList"].arrayValue.map({ return $0["areaNum"].stringValue })
    }
    
}
