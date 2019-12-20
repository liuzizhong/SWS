//
//  SW_WorkReportImageDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkReportImageDetailCell: Cell<[String]>, CellType {
    
    var cacheImageViews = [UIImageView]()
    
    let imageLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        return line
    }()
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lb.text = "图片"
        lb.font = Font(13)
        return lb
    }()
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        setUpSubview()
    }
    
    public override func update() {
        super.update()
        
        setUpSubview()
    }
    
    private func setUpSubview() {
        removeAllSubviews()///添加前将所有子view移除
        guard let value = row.value, value.count > 0 else {
            return
        }
        
//        addSubview(imageLine)
//        imageLine.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.leading.equalTo(15)
//            make.trailing.equalTo(-15)
//            make.height.equalTo(SingleLineWidth)
//        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.leading.equalTo(15)
        }
        
        let columnCount: CGFloat = 5
        let topMargin: CGFloat = 15
        let leftRightMargin: CGFloat = 15
        let margin: CGFloat = 9
        let imageW = (SCREEN_WIDTH - 2 * leftRightMargin - (columnCount - 1) * margin) / columnCount
        
        for index in 0..<value.count {
            let imageView = creatImageView()
            if let url = URL(string: value[index]) {
                imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "work_upload_pictures"))
            }
            
            let row = index / Int(columnCount)//行数
            let column = index % Int(columnCount)//列数
            
            addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(CGFloat(row) * (margin + imageW) + topMargin)
                make.left.equalTo(CGFloat(column) * (margin + imageW) + leftRightMargin)
                make.width.height.equalTo(imageW)
                if index == value.count - 1 {
                    make.bottom.equalTo(-15)
                }
            }
            
        }
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: SingleLineWidth)
    }
    
    private func creatImageView() -> UIImageView {
        if let index = cacheImageViews.firstIndex(where: { return $0.superview == nil }) {
            return cacheImageViews[index]
        } else {
            let imgV = UIImageView()
            imgV.contentMode = .scaleAspectFill
            imgV.layer.masksToBounds = true
            imgV.isUserInteractionEnabled = true
            //点击查看大图
            imgV.addGestureRecognizer(UITapGestureRecognizer { [weak imgV,weak self] (gesture) in
                guard let imgV = imgV else { return }
                let vc = SW_ImagePreviewViewController([imgV.image ?? #imageLiteral(resourceName: "work_upload_pictures")])
                vc.sourceImageView = {
                    return imgV
                }
                self?.getTopVC().present(vc, animated: true, completion: nil)
//                vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                    aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: imgV.superview?.convert(imgV.frame, to: nil) ?? imgV.frame)
//                }
//                vc.startPreviewFromRect(inScreenCoordinate: imgV.superview?.convert(imgV.frame, to: nil) ?? imgV.frame)
            })
            cacheImageViews.append(imgV)
            return imgV
        }
    }
    
}

final class SW_WorkReportImageDetailRow: Row<SW_WorkReportImageDetailCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
