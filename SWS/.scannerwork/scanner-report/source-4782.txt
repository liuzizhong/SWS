//
//  SW_LoadingEmptyView.swift
//  SWS
//
//  Created by jayway on 2019/8/10.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_LoadingEmptyView: LYEmptyView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func creat() -> LYEmptyView {
        let loadingView = YYAnimatedImageView(image: YYImage(named: LoadindImgName))
        loadingView.frame = CGRect(x: 0, y: 0, width: LoadingImgWH, height: LoadingImgWH)
        return LYEmptyView.emptyView(withCustomView: loadingView)
    }

}


/// 无数据占位图
class SW_NoDataEmptyView: LYEmptyView {
    
    class func creat() -> LYEmptyView {
        let emptyView = LYEmptyView.empty(withImageStr: "bg_no_data", titleStr: "暂无数据", detailStr: "")
        emptyView?.titleLabFont = Font(16)
        emptyView?.titleLabTextColor = UIColor.v2Color.emptyTextColor
        emptyView?.subViewMargin = 15
        return emptyView!
    }
    
}
