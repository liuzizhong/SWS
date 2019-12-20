//
//  SW_QualityDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/6.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_QualityDetailViewController: UIViewController {
    
    private var bUnitId = 0
    
    private var repairOrderId = ""
    
    private var isRequesting = false
    
    private var recordData: SW_RepairOrderRecordDetailModel!
    
    private let qualityItemVc = SW_QualityItemFormViewController()
    
    private var pageTitles = ["维修项目","维修配件"]
    
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
        return header
    }()
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: self.view.bounds, viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let strongSelf = self else { return UIView() }
            let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: strongSelf.recordData.customerNameHeight+125))
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
    
    private var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.setTitle("完成质检", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(qualityAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    class func creatVc(_ repairOrderId: String, bUnitId: Int) -> SW_QualityDetailViewController {
        let vc = SW_QualityDetailViewController()
        vc.repairOrderId = repairOrderId
        vc.bUnitId = bUnitId
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        pageControllers = [qualityItemVc,SW_RepairOrderItemFormViewController()]
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
        bottomView.blueBtn.snp.remakeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.equalTo(5)
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
        qualityItemVc.items = recordData.repairOrderItemList
        (pageControllers[1] as? SW_RepairOrderItemFormViewController)?.items = recordData.repairOrderAccessoriesList
    }
    
    private func requestDetailDatas() {
        SW_AfterSaleService.getConstructionDetail(repairOrderId, bUnitId: bUnitId, type: 2).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordData = SW_RepairOrderRecordDetailModel(json)
                self.setup()
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
    
    @objc private func qualityAction(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        SW_TextViewModalView.show(title: "质检意见", placeholder: "请输入质检意见(特别是不合格时)", limitCount: 300, sureBlock: { [weak self] (text) in
            guard let self = self else { return }
            guard !self.isRequesting else { return }
            self.isRequesting = true
            SW_AfterSaleService.qualityStateChange(self.recordData.repairOrderId, repairOrderItemList: self.recordData.repairOrderItemList, remark: text).response({ (json, isCache, error) in
                if let _ = json as? JSON, error == nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.OrderListHadBeenChange, object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                self.isRequesting = false
            })
        })
        
    }
    
}

extension SW_QualityDetailViewController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        print("offset --> ", offsetY)
    }
}

