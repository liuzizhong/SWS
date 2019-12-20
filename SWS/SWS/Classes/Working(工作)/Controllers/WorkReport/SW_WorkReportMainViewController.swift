//
//  SW_WorkReportMainViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportMainViewController: UIViewController {
    
    private var bottomView: SW_WorkReportBottomView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_WorkReportBottomView.self), owner: self, options: nil)?.first as! SW_WorkReportBottomView
        return view
    }()
    
    private lazy var wirteReportBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 44)
        btn.setTitle("写报告", for: UIControl.State())
        btn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        btn.titleLabel?.font = Font(14)
        btn.addTarget(self, action: #selector(creatWorkReport(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var popupAtBarButtonItem: QMUIPopupMenuView!
    
    private var receiveVc = SW_WorkReportManageViewController(.received)
    
    private var mineVc = SW_WorkReportManageViewController(.mine)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func creatWorkReport(_ sender: UIBarButtonItem) {
        if popupAtBarButtonItem.isShowing() {
            popupAtBarButtonItem.hideWith(animated: true)
        } else {
            popupAtBarButtonItem.sourceView = wirteReportBtn
//            popupAtBarButtonItem.layout(withTargetView: wirteReportBtn)
            popupAtBarButtonItem.showWith(animated: true)
        }
    }
    
    /// 对控制器的一些初始化操作
    private func setup() {
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: wirteReportBtn)
        popupAtBarButtonItem = QMUIPopupMenuView()
        popupAtBarButtonItem.maskViewBackgroundColor = .clear
        popupAtBarButtonItem.automaticallyHidesWhenUserTap = true
        popupAtBarButtonItem.itemTitleFont = Font(14)
        popupAtBarButtonItem.itemTitleColor = UIColor.v2Color.lightBlack
        popupAtBarButtonItem.itemHeight = 44
        popupAtBarButtonItem.safetyMarginsOfSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15)
        popupAtBarButtonItem.itemConfigurationHandler = { (menuView,item,section,index) in
            print(index)
            if let item = item as? QMUIPopupMenuButtonItem {
                item.button.highlightedBackgroundColor = .clear
                item.button.setTitleColor(UIColor.v2Color.blue, for: .highlighted)
            }
        }
        popupAtBarButtonItem.padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        popupAtBarButtonItem.borderWidth = 0
        popupAtBarButtonItem.cornerRadius = 3
        popupAtBarButtonItem.shadowColor = UIColor(r: 48, g: 55, b: 80, alpha: 1).withAlphaComponent(0.3)
        popupAtBarButtonItem.arrowSize = CGSize(width: 10, height: 5)
        popupAtBarButtonItem.maximumWidth = 96
        popupAtBarButtonItem.shouldShowItemSeparator = false
        popupAtBarButtonItem.items = [QMUIPopupMenuButtonItem(image: nil, title: "工作日志") { [weak self] (item) in
            self?.popupAtBarButtonItem.hideWith(animated: true)
            
            if let vc = UIStoryboard(name: "Working", bundle: nil).instantiateViewController(withIdentifier: "SW_SelectWorkTypeViewController") as? SW_SelectWorkTypeViewController {
                vc.dismissBlock = { [weak self] (workTypes) in
                    let editVc = SW_EditWorkReportViewController(.day)
                    editVc.reportModel.workTypes = workTypes
                    self?.navigationController?.pushViewController(editVc, animated: true)
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            },QMUIPopupMenuButtonItem(image: nil, title: "月度报告") { [weak self] (item) in
                self?.popupAtBarButtonItem.hideWith(animated: true)
                self?.navigationController?.pushViewController(SW_EditWorkReportViewController(.month), animated: true)
            },QMUIPopupMenuButtonItem(image: nil, title: "年度报告") { [weak self] (item) in
                self?.popupAtBarButtonItem.hideWith(animated: true)
                self?.navigationController?.pushViewController(SW_EditWorkReportViewController(.year), animated: true)
            }]
        
        view.addSubview(bottomView)
        bottomView.receivedBtnBlock = { [weak self] in
            guard let `self` = self else { return }
            self.mineVc.view.removeFromSuperview()
            self.addChileVcView(self.receiveVc)
        }
        bottomView.mineBtnBlock = { [weak self] in
            guard let `self` = self else { return }
            self.receiveVc.view.removeFromSuperview()
            self.addChileVcView(self.mineVc)
        }
        bottomView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM_INTERVAL + TABBAR_HEIGHT)
        }
        bottomView.transform = CGAffineTransform(translationX: 0, y: bottomView.height)
        UIView.animate(withDuration: 0.6) {
            self.bottomView.transform = CGAffineTransform.identity
        }
        addChild(receiveVc)
        addChild(mineVc)
        
        addChileVcView(mineVc)
        
    }

    private func addChileVcView(_ toVc: UIViewController) {
        view.addSubview(toVc.view)
        view.bringSubviewToFront(bottomView)
        toVc.view.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.leading.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        toVc.didMove(toParent: self)
        
        self.navigationItem.title = toVc.navigationItem.title
//        self.navigationItem.rightBarButtonItem = toVc.navigationItem.rightBarButtonItem
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
