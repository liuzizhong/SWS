//
//  SW_WorkReportCommentView.swift
//  SWS
//
//  Created by jayway on 2018/7/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum CommentViewState {
    case showInput
    case hideInput
}

class SW_WorkReportCommentView: UIView {
    
    private var state = CommentViewState.hideInput
    
    private var textView: SW_TextView = {
        let textV = SW_TextView(frame: CGRect.zero)
        textV.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1)
        textV.layer.cornerRadius = 3
        textV.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        textV.layer.borderWidth = 0.5
        textV.layer.masksToBounds = true
        textV.textContainerInset = UIEdgeInsets(top: 10, left: 3, bottom: 0, right: 3)
        textV.limitCount = 300
        textV.placeholderText = "在这里输入审阅意见,给团队打气"
        textV.placeholderTextColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
        
        return textV
    }()
    
    private var tipLabel: UILabel = {
        let lb = UILabel()
        lb.text = "0/300"
        lb.font = Font(14)
        lb.textColor = UIColor.mainColor.blue
        return lb
    }()
    
    private var commemtBtn: SW_BlueButton = {
        let btn = SW_BlueButton()
        btn.setTitle("审阅", for: UIControl.State())
        btn.addTarget(self, action: #selector(commemtBtnAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    var commentBtnBlock: NormalBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupSubView() {
        backgroundColor = UIColor.white
       
        addShadow()//设置阴影的偏移量
        
        textView.textViewChangeBlock = { [weak self] (textView) in
            self?.tipLabel.text = "\(textView.text.count)/300"
            ///计算文字高度改变textview的高度
            self?.setupCommentViewState(0.25, toState: .showInput, force: true)
        }
        
        addSubview(textView)
        addSubview(tipLabel)
        addSubview(commemtBtn)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(8).priority(.medium)
            make.bottom.equalTo(-45 - TABBAR_BOTTOM_INTERVAL).priority(.medium)
            make.height.equalTo(getTextViewHeight())
            make.leading.equalTo(15)
            make.trailing.equalTo(-15).priority(.medium)
        }
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.leading.equalTo(15)
//            make.bottom.equalTo(-14)
        }
        commemtBtn.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(5).priority(.medium)
//            make.bottom.equalTo(-6).priority(.medium)
            make.trailing.equalTo(-15)
            make.width.equalTo(66)
            make.height.equalTo(33)
        }
        
        setupCommentViewState(0, toState: .hideInput, force: true)
    }
    
    
    @objc private func commemtBtnAction(_ sender: UIButton) {
        commentBtnBlock?()
    }
    
    func setupCommentViewState(_ duration: CGFloat, toState: CommentViewState, force: Bool = false) {
        guard state != toState || force else { return }//同一个状态不改变UI
        state = toState
        textView.snp.updateConstraints { (update) in
            update.height.equalTo(getTextViewHeight())
        }
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.textView.layoutIfNeeded()
        }
    }

    ///返回textview的高度
    private func getTextViewHeight() -> CGFloat {
        guard let text = textView.text, !text.isEmpty else { return 33 }
        //有文字
        let textH = ceil(text.size(Font(14), width: SCREEN_WIDTH - 36).height) + 10
        return max(33, min(textH, 80))//80是最大高度 33是最小高度
    }
    
    func getCommentText() -> String {
        guard let text = textView.text else { return "" }
        return text
    }
}
