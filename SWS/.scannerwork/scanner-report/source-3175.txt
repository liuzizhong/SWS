//
//  SW_MineTopView.swift
//  SWS
//
//  Created by jayway on 2018/1/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_MineTopView: UIView {

    var iconImageView: UIImageView?     //头像ImageView
    
    var nameLable: UILabel?             //姓名Lable
    var positionLable: UILabel?              //职务Lable
//    var departmentLable: UILabel?       //部门Lable
    
    var personInfoBlock: (()->Void)?
    
    var messageModel: UserModel?  { //用户
        didSet
        {
            valuationInMineTopView()
        }
    }
    
    func valuationInMineTopView() -> Void {
        guard let messageModel = messageModel else { return }
        
        nameLable?.text = messageModel.realName
        
        positionLable?.text = messageModel.position
        
//        departmentLable?.text = messageModel.businessUnitName + " " + messageModel.departmentName
      
        changePortrait()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createChildViewToMineTopView()
    }
    
    //MARK: -创建子控件
    func createChildViewToMineTopView() -> Void {
        //1.创建上部门蓝灰色View
//        let topBgView = UIImageView()
//        topBgView.image = #imageLiteral(resourceName: "Mine_headerbg").stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
//        .stretchableImage(withLeftCapWidth: 1, topCapHeight: 1)
//        addSubview(topBgView)
//        topBgView.snp.makeConstraints { (make) -> Void in
//            make.left.right.top.equalToSuperview()
//            make.bottom.equalTo(-39 * AUTO_IPHONE6_HEIGHT_667)
//            make.height.equalTo(160 * AUTO_IPHONE6_HEIGHT_667)
//        }
//        topBgView.layoutIfNeeded()
//        topBgView.layer.addGradationBack(from: HexStringToColor("#4f539d"), to: HexStringToColor("#363981"))
        
//        Mine_headerbg
        
        //2.创建上层的View  白色cardview   添加点击手势
        let emersionView = UIView.init()
        if let tap = UITapGestureRecognizer(actionBlock: { (sender) in
            self.personInfoBlock?()
        }) {
            emersionView.addGestureRecognizer(tap)
        }
        addSubview(emersionView)
        emersionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview().priority(.medium)
        }
        emersionView.backgroundColor = UIColor.white
//        emersionView.layer.cornerRadius = 2
//        emersionView.layer.masksToBounds = true
//        emersionView.addShadow()//设置阴影的偏移量
        
        //1.初始化iconImageView
        iconImageView = UIImageView.init()
        guard let iconImageView = iconImageView else { return }
        emersionView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) -> Void in
            make.trailing.equalTo(-15)
            make.bottom.equalTo(-40)
            make.width.height.equalTo(80)
        }
        iconImageView.layer.cornerRadius = 40
        iconImageView.layer.masksToBounds = true
//        iconImageView.backgroundColor = //HexStringToColor("#aeaeae")
        
        //3.职务Lable
        positionLable = UILabel.init()
        guard let positionLable = positionLable else { return }
        emersionView.addSubview(positionLable)
        positionLable.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(15)
            make.bottom.equalTo(-45)
        }
        positionLable.font = Font(18)
        positionLable.textColor = UIColor.v2Color.darkGray
        
        //2.初始化姓名Lable
        nameLable = UILabel.init()
        guard let nameLable = nameLable else { return }
        emersionView.addSubview(nameLable)
        nameLable.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(15)
            make.bottom.equalTo(-81)
        }
        nameLable.font = BlackFont(24)
        nameLable.textColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
        nameLable.text = "李思婉"
        
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(15).priority(.medium)
            make.trailing.equalTo(-15).priority(.medium)
            make.bottom.equalToSuperview()
            make.height.equalTo(SingleLineWidth)
        }
        //4.部门Lable
//        departmentLable = UILabel.init()
//        guard let departmentLable = departmentLable else { return }
//        emersionView.addSubview(departmentLable)
//        departmentLable.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(positionLable)
//            make.top.equalTo(positionLable.snp.bottom).offset(8 * AUTO_IPHONE6_HEIGHT_667)
//        }
//        departmentLable.textColor = UIColor.mainColor.darkBlack
//        departmentLable.font = Font(12)
//        departmentLable.text = "三惠集团-惠州区域-宝沃沃尔沃-销售部"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePortrait), name: NSNotification.Name.Ex.UserPortraitHadChange, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changePortrait() {
        guard let messageModel = messageModel else { return }
        if let url = URL(string: messageModel.portrait) {
            iconImageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
        } else {
            iconImageView?.image = UIImage(named: "icon_personalavatar")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
