//
//  SW_RepairOrderRecordDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/2/27.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_RepairOrderRecordDetailViewController: FormViewController {
    
    private var pageType = AuditRepairOrderPageType.item {
        didSet {
            if pageType != oldValue {
                createTableView()
            }
        }
    }
    /// 要新增活动套餐
    private lazy var typeHeaderRow: SW_AuditRepairOrderTypeHeaderRow = { [weak self] in
        let row = SW_AuditRepairOrderTypeHeaderRow("SW_AuditRepairOrderTypeHeaderRow") {
            $0.isHideSuggest = false
            $0.typeChangeBlock = { (infoType) in
                self?.pageType = infoType
            }
            $0.value = self?.pageType
        }
        return row
    }()
    
    /// 这些view要全部重做  活动套餐可以用一个
    private lazy var itemRow: SW_RepairOrderRecordDetailItemFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailItemFormRow("SW_RepairOrderRecordDetailItemFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderItemList
        }
        return row
        }()
    
    private lazy var accessoriesRow: SW_RepairOrderRecordDetailAccessoriesFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailAccessoriesFormRow("SW_RepairOrderRecordDetailAccessoriesFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderAccessoriesList
        }
        return row
        }()
    
    private lazy var boutiqueRow: SW_RepairOrderRecordDetailBoutiquesFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailBoutiquesFormRow("SW_RepairOrderRecordDetailBoutiquesFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderBoutiquesList
        }
        return row
        }()
    
    private lazy var otherRow: SW_RepairOrderRecordDetailOtherFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailOtherFormRow("SW_RepairOrderRecordDetailOtherFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderOtherInfoList
        }
        return row
        }()
    
    private lazy var repairPackageRow: SW_AuditRepairOrderPackageFormRow = { [weak self] in
        let row = SW_AuditRepairOrderPackageFormRow("SW_AuditRepairOrderPackageFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairPackageItemList
        }
        return row
    }()
    
    private lazy var couponsRow: SW_RepairOrderRecordDetailCouponsFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailCouponsFormRow("SW_RepairOrderRecordDetailCouponsFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderCouponsList
        }
        return row
        }()
    
    private lazy var suggestRow: SW_RepairOrderRecordDetailSuggestFormRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailSuggestFormRow("SW_RepairOrderRecordDetailSuggestFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.suggestItemList
        }
        return row
    }()
    
    private lazy var infoRow: SW_RepairOrderRecordDetailInfoRow = { [weak self] in
        let row = SW_RepairOrderRecordDetailInfoRow("SW_RepairOrderRecordDetailInfoRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder
        }
        return row
    }()
    
    private var repairOrderId = ""
    private var repairOrder: SW_RepairOrderRecordDetailModel!
    private var isConstruction = false
    
    class func creatVc(_ repairOrderId: String, isConstruction: Bool) -> SW_RepairOrderRecordDetailViewController {
        let vc = SW_RepairOrderRecordDetailViewController()
        vc.repairOrderId = repairOrderId
        vc.isConstruction = isConstruction
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requestDetailDatas()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
//        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 100) * 0.1
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
            cell.rightLb.font = Font(14)
            cell.rightLb.textColor = UIColor.v2Color.blue
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            if type == .repairOrder, orderId == self?.repairOrder?.repairOrderId {
                guard let row = self?.form.rowBy(tag: "Customer complaints") as? SW_StaffInfoRow else {
                    return
                }
                row.value = "待审核"
                row.rightValue = "详情"
                row.updateCell()
            }
        }
    }
    private var aSection: Eureka.Section!
    private func createTableView() {
        guard let repairOrder = repairOrder else { return }
        navigationItem.title = repairOrder.repairOrderNum
        aSection = Eureka.Section()
        form = Form()
            +++  aSection
            <<< SW_StaffInfoRow("receivableAmount") {
                $0.rowTitle = NSLocalizedString("应 收 金 额   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.receivableAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("repairInsuranceCompanys") {
                $0.rowTitle = NSLocalizedString("赔 付 公 司   ", comment: "")
                $0.isShowBottom = false
                var str = ""
                repairOrder.repairInsuranceCompanys.forEach({ str += "\($0.name)\($0.percent)%；" })
                $0.value = str.isEmpty ? "无" : str
            }
            <<< SW_StaffInfoRow("createDate") {
                $0.rowTitle = NSLocalizedString("入 厂 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.createDate == 0 ? "" :  Date.dateWith(timeInterval: repairOrder.createDate).simpleTimeString(formatter: .yearMinite)
            }
            <<< SW_StaffInfoRow("completeDate") {
                $0.rowTitle = NSLocalizedString("出 厂 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.completeDate == 0 ? "无" : Date.dateWith(timeInterval: repairOrder.completeDate).simpleTimeString(formatter: .yearMinite)
            }
            <<< SW_StaffInfoRow("sender") {
                $0.rowTitle = NSLocalizedString("送   修    人   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.sender
            }
            <<< SW_StaffInfoRow("senderPhone") {
                $0.rowTitle = NSLocalizedString("送修人电话   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.senderPhone
            }
            <<< SW_StaffInfoRow("remark") {
                $0.rowTitle = NSLocalizedString("接 车 备 注   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.remark
            }
            <<< infoRow
        
        form
            +++
            Eureka.Section()
            <<< typeHeaderRow
        
        switch pageType {
        case .item:
            form.last! <<< itemRow
        case .accessories:
            form.last! <<< accessoriesRow
        case .boutique:
            form.last! <<< boutiqueRow
        case .other:
            form.last! <<< otherRow
        case .repairPackage:
            form.last! <<< repairPackageRow
        case .coupons:
            form.last! <<< couponsRow
        case .suggest:
            form.last! <<< suggestRow
        }
        
        if !isConstruction {
            if repairOrder.customerServingItemScores.count > 0  || repairOrder.nonGrandedItems.count > 0 {
                aSection.insert(SW_StaffInfoRow("Customer rating") {
                    $0.rowTitle = NSLocalizedString("回 访 记 录   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =   repairOrder.customerServingItemScores.count > 0 ? "\(repairOrder.getScore.toAmoutString())分" : "已回访"
                    $0.rightValue = "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        PrintLog("goto ")
                        self?.navigationController?.pushViewController(SW_CustomerScoreManagerViewController(repairOrder.customerServingItemScores, nonScoreItems: repairOrder.nonGrandedItems), animated: true)
                    }), at: 0)
                
            }
            if repairOrder.complaintRecords.count > 0 {
                aSection.insert(SW_StaffInfoRow("Customer complaints") {
                    $0.rowTitle = NSLocalizedString("客 户 投 诉   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = repairOrder.complaintState.rawTitle
                    $0.rightValue = repairOrder.complaintState == .waitHandle ? "处理" : "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    PrintLog("goto ")
                    let vc = SW_ComplaintsListViewController.creatVc(repairOrder.complaintRecords, phone: repairOrder.customerPhoneNum)
                    self?.navigationController?.pushViewController(vc, animated: true)
                    }), at: 0)
            }
            
        }
        
        tableView.reloadData()
    }
   
    private func requestDetailDatas() {
        SW_AfterSaleService.getRepairOrderDetail(repairOrderId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.repairOrder = SW_RepairOrderRecordDetailModel(json, shouldCombined: true)
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    

//MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    }

    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
}
