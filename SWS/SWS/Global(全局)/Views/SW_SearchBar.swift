//
//  SW_SearchBar.swift
//  SWS
//
//  Created by jayway on 2018/1/15.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

typealias PhoneChangeBlock = (String?)->Void

class SW_SearchBar: UIView, UITextFieldDelegate {
    private var cancleButton: UIButton! //搜索按钮
    private var searchBgView: UIView!
    var searchField: UITextField!        //搜索输入框
    var cancelBlock: NormalBlock?        //取消按钮点击调用闭包
    var searchMessageBlock: PhoneChangeBlock?   //搜索内容改变闭包
    var searchBlock: NormalBlock?        //搜索按钮点击事件
    var maxCount: Int?
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatChildViewToSearchBar()     //创建搜索框子控件
    }
    
    func creatChildViewToSearchBar() -> Void {
        //1.搜索框背景
        searchBgView = UIView.init()
        addSubview(searchBgView)
        searchBgView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        searchBgView.layer.cornerRadius = 3
        searchBgView.addShadow()
        searchBgView.backgroundColor = UIColor.white
        //2.中间输入框
        searchField = UITextField.init()
        searchBgView.addSubview(searchField)
        searchField.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(55)
            make.right.bottom.top.equalToSuperview()
        }
        searchField.backgroundColor = UIColor.clear
        searchField.placeholder = InternationStr("搜索")
        searchField.font = Font(16)
        searchField.tintColor = UIColor.v2Color.blue
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.addTarget(self, action: #selector(searchMessasgeChange(_:)), for: .editingChanged)
        searchField.delegate = self
        
        //3.左侧搜索图片
        let searchIcon = UIImageView.init()
        searchBgView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(21)
        }
        searchIcon.image = #imageLiteral(resourceName: "Main_Search")
        
        //1.创建搜索框右侧的取消字体
        cancleButton = UIButton.init()
        addSubview(cancleButton)
        cancleButton.snp.makeConstraints { (make) -> Void in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(searchBgView.snp.right)
            make.width.equalTo(60)
        }
        cancleButton.setTitle(InternationStr("取消"), for: .normal)
        cancleButton.setTitleColor(UIColor.v2Color.blue, for: .normal)
        cancleButton.titleLabel?.font = Font(14)
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
    }
    
    //MARK: -搜索内容改变
    @objc private func searchMessasgeChange(_ textFiled: UITextField) {
        guard let searchMessageBlock = searchMessageBlock else { return }
        searchMessageBlock(textFiled.text)
    }
    
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchBlock = searchBlock else { return  true}
        textField.resignFirstResponder()
        searchBlock()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        if let maxCount = maxCount {
            //设置了限制长度 名字最多6位 可以改
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > maxCount {
                return false
            }
        }
        return true
    }
    
    ///取消按钮点击事件
    @objc private func cancleButtonClick() -> Void {
        guard let cancelBlock = cancelBlock else { return }
        cancelBlock()
    }
    
    //MARK: - plub
    func changeCancelBtnHiddenState(isShow: Bool = true) {
        cancleButton.isHidden = !isShow
        if isShow {
            searchBgView.snp.remakeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(15)
                make.centerY.equalToSuperview()
                make.height.equalTo(44)
            }
        } else {
            searchBgView.snp.remakeConstraints { (make) -> Void in
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
                make.height.equalTo(44)
//                make.width.equalTo(345 * AUTO_IPHONE6_WIDTH_375)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
