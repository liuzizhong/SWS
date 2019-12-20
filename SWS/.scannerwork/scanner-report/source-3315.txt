//
//  SW_ConstructionDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/5.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ConstructionDetailViewController: UIViewController {
    
    private var bUnitId = 0
    
    private var repairOrderId = ""
    
    private var isRequesting = false
    
    private var recordData: SW_RepairOrderRecordDetailModel!
    
    private var isInvalid = false
    
    private let constructionItemVc = SW_ConstructionItemFormViewController()
    
    private let constructionAccessoriesVc = SW_ConstructionAccessoriesFormViewController()
    
    private var pageTitles = ["维修项目","维修配件","建议项目"]
    
    private var pageControllers: [UIViewController]!
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.titleFont = Font(16)
        layout.titleMargin = min((SCREEN_WIDTH - 294) / 3, 40)
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let Y: CGFloat = 0//NAV_HEAD_INTERVAL + 74
        let H: CGFloat = SCREEN_HEIGHT - NAV_TOTAL_HEIGHT//NAV_HEAD_INTERVAL - 74
        return CGRect(x: 0, y: Y, width: view.bounds.width, height: H)
    }
    
    private lazy var headerView: SW_OrderDetailBaseInfoHeader = {
        let header = Bundle.main.loadNibNamed(String(describing: SW_OrderDetailBaseInfoHeader.self), owner: nil, options: nil)?.first as! SW_OrderDetailBaseInfoHeader
        header.repairRecordBtn.isHidden = false
        header.repairRecordBlock = { [weak self] in
            let vc = SW_AfterSaleAccessRecordViewController(type: .repairOrder, vin: self?.recordData.vin ?? "", repairOrderId: "", customerId: "", isConstruction: true)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return header
    }()
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: self.view.bounds, viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let strongSelf = self else { return UIView() }
                let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: strongSelf.recordData.customerNameHeight+170))
                strongSelf.headerView.orderModel = strongSelf.recordData
                view.addSubview(strongSelf.headerView)
                strongSelf.headerView.snp.makeConstraints { (make) in
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
    
    
    lazy var bottomView: SW_ConstructionDetailBottomView = {
        let view = Bundle.main.loadNibNamed("SW_ConstructionDetailBottomView", owner: nil, options: nil)?.first as! SW_ConstructionDetailBottomView
        view.startActionBlock = { [weak self] in
            self?.startAction()
        }
        view.completeActionBlock = { [weak self] in
            self?.completeAction()
        }
        return view
    }()
    
    class func creatVc(_ repairOrderId: String, bUnitId: Int, isInvalid: Bool) -> SW_ConstructionDetailViewController {
        let vc = SW_ConstructionDetailViewController()
        vc.repairOrderId = repairOrderId//"ff8080816bda0c6f016bda6c3f050021"
        vc.bUnitId = bUnitId
        vc.isInvalid = isInvalid
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        constructionItemVc.isInvalid = isInvalid
        constructionItemVc.addBlock = { [weak self] in
            PrintLog("维修项目增项")
            self?.navigationController?.pushViewController(SW_AppendRepairItemViewController(self?.repairOrderId ?? "", successBlock: {
                self?.requestDetailDatas(setup: false)
            }), animated: true)
        }
        constructionAccessoriesVc.addBlock = { [weak self] in
            PrintLog("配件增项")
            self?.navigationController?.pushViewController(SW_AppendAccessoriesItemViewController(self?.repairOrderId ?? "", successBlock: {
                self?.requestDetailDatas(setup: false)
            }), animated: true)
        }
        pageControllers = [constructionItemVc,constructionAccessoriesVc,SW_RepairOrderItemFormViewController()]
        pageControllers.forEach({ $0.view.backgroundColor = .white })
        requestDetailDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setup() {
        navigationItem.title = recordData.repairOrderNum
       
        view.addSubview(advancedManager)
        
        advancedManagerConfig()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM_INTERVAL + 54)
        }
        constructionItemVc.isHideAddbtn = recordData.qualityState == .waitQuality || isInvalid
        constructionAccessoriesVc.isHideAddbtn =  recordData.qualityState == .waitQuality || isInvalid
        constructionItemVc.items = recordData.repairOrderItemList
        constructionAccessoriesVc.items = recordData.repairOrderAccessoriesList
        (pageControllers[2] as? SW_RepairOrderItemFormViewController)?.items = recordData.suggestItemList
        
        bottomView.isHidden = constructionItemVc.canSelectItems.count == 0
    }
    
    private func requestDetailDatas(setup: Bool = true) {
        SW_AfterSaleService.getConstructionDetail(repairOrderId, bUnitId: bUnitId, type: 1).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordData = SW_RepairOrderRecordDetailModel(json)
                if setup {
                    self.setup()
                } else {
                    self.constructionItemVc.items = self.recordData.repairOrderItemList
                    self.constructionAccessoriesVc.items = self.recordData.repairOrderAccessoriesList
                    (self.pageControllers[2] as? SW_RepairOrderItemFormViewController)?.items = self.recordData.suggestItemList
                     self.bottomView.isHidden = self.constructionItemVc.canSelectItems.count == 0
                    self.headerView.orderModel = self.recordData
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
    
    private func startAction() {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        guard !isRequesting else { return }
        let selectItems = constructionItemVc.selectItems
        if selectItems.count == 0 {
            showAlertMessage("请选择维修项目", MYWINDOW)
            return
        }
        isRequesting = true
        QMUITips.showLoading("正在开工", in: self.view)
        SW_AfterSaleService.constructionStateChange(recordData.repairOrderId, repairOrderItemList: selectItems, state: .start).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("维修项目状态已更新", MYWINDOW)
                self.requestDetailDatas(setup: false)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
        })
    }
    
    private func completeAction() {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        guard !isRequesting else { return }
        let selectItems = constructionItemVc.selectItems
        if selectItems.count == 0 {
            showAlertMessage("请选择维修项目", MYWINDOW)
            return
        }
        isRequesting = true
        QMUITips.showLoading("正在完工", in: self.view)
        SW_AfterSaleService.constructionStateChange(recordData.repairOrderId, repairOrderItemList: selectItems, state: .completed).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("维修项目状态已更新", MYWINDOW)
                self.requestDetailDatas(setup: false)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
        })
    }
}

extension SW_ConstructionDetailViewController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
                print("offset --> ", offsetY)
    }
}

