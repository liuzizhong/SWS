//
//  SW_SalesContactsFilterHeaderView.swift
//  SWS
//
//  Created by jayway on 2019/11/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContactsFilterHeaderView: UIView {

    @IBOutlet var typeBtns: [SW_ShaDowBlueBtn]!
    
    @IBOutlet var levelBtns: [UIButton]!
    
    @IBOutlet var dataPercentBtns: [UIButton]!
    
    @IBOutlet weak var upDownBtn: UIButton!
    
    /// 当前是否收起，箭头向下
    var currentIsDown = true {
        didSet {
            upDownBtn.setImage(currentIsDown ? #imageLiteral(resourceName: "salecustomer_down") : #imageLiteral(resourceName: "salecustomer_up"), for: UIControl.State())
        }
    }
    
    var stateChangeBlock: ((Bool)->Void)?
    
    var newCount = 0
    var waitCount = 0
    var allCount = 0
    
    var selectValueChange: ((Int, CustomerLevel, Int)->Void)?
    
    var selectType = 1 {
        didSet {
            if selectType != oldValue {
                selectValueChange?(selectType, selectLevel, selectDataPercent)
            }
        }
    }
    var selectLevel: CustomerLevel = .none {
        didSet {
            if selectLevel != oldValue {
                selectValueChange?(selectType, selectLevel, selectDataPercent)
            }
        }
    }
    var selectDataPercent = 0 {
        didSet {
            if selectDataPercent != oldValue {
                selectValueChange?(selectType, selectLevel, selectDataPercent)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        getCutomerCount()
        setTypeBtns()
        typeBtns.forEach { [weak self] (view) in
            view.blueBtn.addTarget(self, action: #selector(typeBtnsClick(_:)), for: .touchUpInside)
            view.isSelected = view.tag - 100 == self?.selectType
        }
        levelBtns.forEach { [weak self] (btn) in
            btn.layer.cornerRadius = 3
            btn.layer.borderWidth = 0.5
            btn.setTitleColor(UIColor.v2Color.blue, for: .selected)
            btn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: .selected)
            btn.setBackgroundImage(UIImage.image(solidColor: UIColor.mainColor.background, size: CGSize(width: 1, height: 1)), for: UIControl.State())
            self?.setButton(btn, isSelected: btn.tag - 200 == self?.selectLevel.rawValue)
        }
        dataPercentBtns.forEach { [weak self] (btn) in
            btn.layer.cornerRadius = 3
            btn.layer.borderWidth = 0.5
            btn.setTitleColor(UIColor.v2Color.blue, for: .selected)
            btn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: .selected)
            btn.setBackgroundImage(UIImage.image(solidColor: UIColor.mainColor.background, size: CGSize(width: 1, height: 1)), for: UIControl.State())
            self?.setButton(btn, isSelected: btn.tag - 300 == self?.selectDataPercent)
        }
    }
    
    @objc func typeBtnsClick(_ sender: UIButton) {
        typeBtns.forEach { [weak self] (view) in
            if view.blueBtn == sender {
                view.isSelected = true
                self?.selectType = view.tag - 100
            } else {
                view.isSelected = false
            }
        }
    }
    @IBAction func upDownBtnClick(_ sender: UIButton) {
        currentIsDown = !currentIsDown
        stateChangeBlock?(currentIsDown)
    }
    
    @IBAction func levelBtnsClick(_ sender: UIButton) {
        /// 取消选择
        if sender.tag - 200 == selectLevel.rawValue {
            setButton(sender, isSelected: false)
            selectLevel = .none
        } else {
            levelBtns.forEach { [weak self] (btn) in
                self?.setButton(btn, isSelected: false)
            }
            setButton(sender, isSelected: true)
            selectLevel = CustomerLevel(rawValue: sender.tag - 200) ?? .none
        }
    }
    
    @IBAction func dataPercentBtnsClick(_ sender: UIButton) {
        /// 取消选择
        if sender.tag - 300 == selectDataPercent {
            setButton(sender, isSelected: false)
            selectDataPercent = 0
        } else {
            dataPercentBtns.forEach { [weak self] (btn) in
                self?.setButton(btn, isSelected: false)
            }
            setButton(sender, isSelected: true)
            selectDataPercent = sender.tag - 300
        }
    }
    
    private func setButton(_ btn: UIButton, isSelected: Bool) {
        btn.layer.borderColor = isSelected ? UIColor.v2Color.blue.cgColor : UIColor.v2Color.disable.cgColor
        btn.isSelected = isSelected
    }
    
    private func setTypeBtns() {
        typeBtns[0].titleLb.text = "最近新客"
        typeBtns[0].countLb.text = "(\(newCount))"
        typeBtns[1].titleLb.text = "待访问"
        typeBtns[1].countLb.text = "(\(waitCount))"
        typeBtns[2].titleLb.text = "全部"
        typeBtns[2].countLb.text = "(\(allCount))"
    }
    
    func getCutomerCount() {
        SW_AddressBookService.getCutomerCount().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.newCount = json["newVisitCount"].intValue
                self.waitCount = json["waitAccessCount"].intValue
                self.allCount = json["totalCount"].intValue
                self.setTypeBtns()
            }
        })
    }
    
}





