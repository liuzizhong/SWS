//
//  SW_ShaDowBlueBtn.swift
//  SWS
//
//  Created by jayway on 2019/11/13.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ShaDowBlueBtn: UIView {
    
    var blueBtn: UIButton = {
        let btn = UIButton()
        btn.clipsToBounds = true
        return btn
    }()
    
    var titleLb: UILabel = {
        let lb = UILabel()
        lb.font = MediumFont(12)
        lb.textAlignment = .center
        return lb
    }()
    
    var countLb: UILabel = {
        let lb = UILabel()
        lb.font = Font(11)
        lb.textAlignment = .center
        return lb
    }()
    
    var isSelected = false {
        didSet {
            blueBtn.isSelected = isSelected
            titleLb.textColor = isSelected ? UIColor.white : UIColor.v2Color.darkGray
            countLb.textColor = isSelected ? UIColor.white : #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
            addShadow(isSelected ? UIColor.v2Color.blue.withAlphaComponent(0.5) : UIColor.black.withAlphaComponent(0.1))
            blueBtn.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.v2Color.disable.cgColor
        }
    }
    
    var isShowCount = true {
        didSet {
            setLbSnp()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBtn()
    }
    
    func setupBtn() {
        backgroundColor = .clear
        blueBtn.layer.cornerRadius = 3
        blueBtn.layer.borderWidth = 0.5
        blueBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.v2Color.blue, size: CGSize(width: 1, height: 1)), for: .selected)
        //        blueBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.v2Color.blue.withAlphaComponent(0.5), size: CGSize(width: 1, height: 1)), for: .highlighted)
        blueBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControl.State())
        addSubview(blueBtn)
        blueBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addSubview(titleLb)
        addSubview(countLb)
        setLbSnp()
        
    }
    
    private func setLbSnp() {
        if isShowCount {
            countLb.isHidden = false
            titleLb.snp.makeConstraints { (make) in
                make.top.equalTo(4)
                make.centerX.equalToSuperview()
            }
            countLb.snp.makeConstraints { (make) in
                make.top.equalTo(titleLb.snp.bottom).offset(-2)
                make.centerX.equalToSuperview()
            }
        } else {
            countLb.isHidden = true
            titleLb.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
    }
    
}
