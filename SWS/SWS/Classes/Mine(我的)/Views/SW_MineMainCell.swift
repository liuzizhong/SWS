//
//  SW_MineMainCell.swift
//  SWS
//
//  Created by jayway on 2018/1/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_MineMainCell: UITableViewCell {

    var iconButton: UIButton?     //左侧图标
    var captionLable: UILabel?            //标题Lable
//    var rightImageView: UIImageView?    //右侧图标
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        creatChildViewToMineMainCell()
    }
    
    //MARK: -创建右侧iconImageView
    func creatChildViewToMineMainCell() -> Void {
        //1.左侧的imageView
        iconButton = UIButton.init()
        guard let iconButton = iconButton else { return }
        contentView.addSubview(iconButton)
        iconButton.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        //2.标题Lable
        captionLable = UILabel.init()
        guard let captionLable = captionLable else { return }
        contentView.addSubview(captionLable)
        captionLable.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        captionLable.font = Font(16)
        captionLable.textColor = UIColor.v2Color.lightBlack

        
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(SingleLineWidth)
        }
        //3.右侧只是imageView
//        rightImageView = UIImageView.init()
//        guard let rightImageView = rightImageView else { return }
//        contentView.addSubview(rightImageView)
//        rightImageView.snp.makeConstraints { (make) -> Void in
//            make.right.equalToSuperview().offset(-10 * AUTO_IPHONE6_WIDTH_375)
//            make.centerY.equalToSuperview()
//        }
//        rightImageView.image = #imageLiteral(resourceName: "Main_NextPage")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
