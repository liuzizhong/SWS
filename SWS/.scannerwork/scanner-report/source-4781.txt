//
//  SW_TextView.swift
//  SWS
//
//  Created by jayway on 2018/1/25.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import YYKit

typealias TextViewDidChangeBlock = (YYTextView)->Void

class SW_TextView: YYTextView {

    var textViewChangeBlock: TextViewDidChangeBlock? {
        didSet {
            myDelegate?.textViewChangeBlock = textViewChangeBlock
        }
    }
    
    var myDelegate: SW_TextViewDelegate?
    
    var limitCount = -1 {//小于0代表不限制字数
        didSet {
            myDelegate?.limitCount = limitCount
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        text = ""
        font = Font(14)
        placeholderFont = Font(14)
        textColor = UIColor.mainColor.darkBlack
        myDelegate = SW_TextViewDelegate()
        delegate = myDelegate
    }
}

class SW_TextViewDelegate: NSObject {
    
    var textViewChangeBlock: TextViewDidChangeBlock?
    
    var limitCount = -1 //小于0代表不限制字数
    
    override init() {
        super.init()
    }
  
}
extension SW_TextViewDelegate: YYTextViewDelegate {
    
    func textViewDidChange(_ textView: YYTextView!) {
        textViewChangeBlock?(textView)
    }
    
    func textView(_ textView: YYTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        if limitCount < 0 { return true }
        
        if textView.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && text.trimmingCharacters(in: CharacterSet.whitespaces).filter({ $0 != "\n" }).isEmpty {
            return false
        }
        /// 如果包含表情，不允许输入
        if (text as NSString).isNineKeyBoard() {
            return true
        } else if (text as NSString).stringContainsEmoji() || (text as NSString).hasEmoji() {
            return false
        }
        
        guard let textViewText = textView.text else {
            return true
        }
//        if range.length > limitCount {
//            return true
//        }
        if textViewText == text, range.length == 0, range.location == 0 {///文本被清空--临时这样处理，不知道有没bugbug
            return true
        }
        let textLength = textViewText.count + text.count - range.length
        if textLength > limitCount {
            let leftcount = limitCount - textViewText.count
            if leftcount <= 0 {
//                MBProgressHUD.showWarningImage(onWindow: "已超过1140个文字")
                return false
            }
            if text.count > leftcount {
                let begin = textView.beginningOfDocument
                guard let start = textView.position(from: begin, offset: range.location),let end = textView.position(from: start, offset: range.length), let _ = textView.textRange(from: start, to: end) else {
                    return true
                }
                return false
            }
        }
        return true
    }
    
    
}
