//
//  SW_AccessBoutiqueReceiveViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AccessBoutiqueReceiveViewController: UIViewController {
    
    private var isHadSave = false
    private var isRequesting = false
    
    private var qrKey = ""
    private var id = ""
    private var operatorId = 0
    /// 领件单号||维修单号||车架号||合同编号
    private var orderNum = ""
    private var type: QrCodeType = .accessoriesReceive
    private var actionTitle = ""
    
    private var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.addTarget(self, action: #selector(sureAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var label: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.v2Color.lightBlack
        lb.numberOfLines = 0
        lb.font = Font(18)
        lb.textAlignment = .center
        return lb
    }()
    
    init(type: QrCodeType,qrKey: String, id: String, orderNum: String, operatorId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.qrKey = qrKey
        self.id = id
        self.orderNum = orderNum
        self.type = type
        self.operatorId = operatorId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case .accessoriesReceive, .boutiqueReceive, .repairAccessoriesOut, .repairBoutiqueOut, .playCarBoutiqueOut, .contractBoutiqueOut:
            actionTitle = "领件"
        default:
            actionTitle = "返库"
        }
        navigationItem.title = type.navTitle
        bottomView.blueBtn.setTitle("确认\(actionTitle)", for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        view.backgroundColor = UIColor.white
        var orderNumTitle = "领件单号"
        switch type {
        case .repairAccessoriesOut, .repairAccessoriesBack, .repairBoutiqueOut, .repairBoutiqueBack:
            orderNumTitle = "维修单号"
        case .playCarBoutiqueOut,.playCarBoutiqueBack:
            orderNumTitle = "车架号"
        case .contractBoutiqueBack,.contractBoutiqueOut:
            orderNumTitle = "合同编号"
        default:
            break
        }
        label.text = "\(orderNumTitle)\n\(orderNum)"
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(15)
            make.trailing.greaterThanOrEqualTo(-15)
        }
        
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
    }
    
    deinit {
        PrintLog("deinit")
        ///调用取消领件接口
        if !isHadSave {
            SW_QrCodeService.accessoriesBoutiqueReceiveOrder(qrKey, id: id, type: type, businessType: 2, operatorId: operatorId, orderNum: orderNum).response({ (json, isCache, error) in
                
            })
        }
    }
    
    @objc private func sureAction(_ sender: UIButton) {
        
        guard !isRequesting else { return }
        isRequesting = true
        SW_QrCodeService.accessoriesBoutiqueReceiveOrder(qrKey, id: id, type: type, businessType: 1, operatorId: operatorId, orderNum: orderNum).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("\(self.actionTitle)成功", MYWINDOW!)
                self.isHadSave = true
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                if let json = json as? JSON, json["code"].int != nil {
                    self.navigationController?.popViewController(animated: true)
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            self.isRequesting = false
        })
        
    }

    @objc private func backAction() {
        alertControllerShow(title: "确定取消\(actionTitle)？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
            self.navigationController?.popToRootViewController(animated: true)
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
}
