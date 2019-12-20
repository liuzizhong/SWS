//
//  SW_CommenTextViewCell.swift
//  SWS
//
//  Created by jayway on 2018/11/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_CommenTextViewCell: Cell<String>, CellType, QMUITextViewDelegate {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var textView: QMUITextView!
    
    @IBOutlet weak var tipLb: UILabel!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    private var rowForCell : SW_CommenTextViewRow? {
        return row as? SW_CommenTextViewRow
    }
    
    @IBOutlet weak var tipBottomLine: UIView!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        guard let rowForCell = rowForCell else { return }
        tipBottomLine.backgroundColor = UIColor.v2Color.blue
        titleLb.text = rowForCell.rawTitle
        textView.shouldResponseToProgrammaticallyTextChanges = false
        textView.maximumHeight = rowForCell.maximumHeight
        textView.delegate = self
        textView.placeholder = rowForCell.placeholder
        textView.text = rowForCell.value
        
        var height = flat(textView.sizeThatFits(CGSize(width: textView.width, height:  CGFloat.greatestFiniteMagnitude)).height)
        height = max(35.5, height)
        if textViewHeightConstraint.constant != height {
            textViewHeightConstraint.constant = height
        }
        
        if let max = rowForCell.maximumTextLength {
            textView.maximumTextLength = max
            tipLb.text = "\(textView.text.count)/\(max)"
        } else {
            tipLb.isHidden = true
        }
    }
    
    public override func update() {
        super.update()
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textView.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return textView.becomeFirstResponder()
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    override func didSelect() {
        super.didSelect()
    }
    
    /**
     *  用户点击键盘的 return 按钮时的回调（return 按钮本质上是输入换行符“\n”）
     *  @return 返回 YES 表示程序认为当前的点击是为了进行类似“发送”之类的操作，所以最终“\n”并不会被输入到文本框里。返回 NO 表示程序认为当前的点击只是普通的输入，所以会继续询问 textView:shouldChangeTextInRange:replacementText: 方法，根据该方法的返回结果来决定是否要输入这个“\n”。
     *  @see maximumTextLength
     */
    func textViewShouldReturn(_ textView: QMUITextView!) -> Bool {
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let max = rowForCell?.maximumTextLength {
            self.tipLb.text = "\(textView.text.count)/\(max)"
        }
        row.value = textView.text
        
        var height = flat(textView.sizeThatFits(CGSize(width: textView.width, height:  CGFloat.greatestFiniteMagnitude)).height)
        height = max(35.5, height)
//        PrintLog(textView.markedTextRange)
        if textViewHeightConstraint.constant != height && textView.markedTextRange == nil {
            textViewHeightConstraint.constant = height
            rowForCell?.textViewHeightChangeBlock?(textViewHeightConstraint.constant)
            ///高度改变时键盘会自动收起，不知道原因
            textView.becomeFirstResponder()
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tipBottomLine.isHidden = false
        tipBottomLine.backgroundColor = UIColor.v2Color.blue
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        tipBottomLine.isHidden = true
        tipBottomLine.backgroundColor = UIColor.v2Color.blue
    }
    
}

final class SW_CommenTextViewRow: Row<SW_CommenTextViewCell>, RowType {
    
    var textViewHeightChangeBlock: ((CGFloat)->Void)?
    
    var rawTitle = ""

    var placeholder = ""
    
    var maximumTextLength: UInt?
    
    var maximumHeight: CGFloat = 200
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CommenTextViewCell>(nibName: "SW_CommenTextViewCell")
    }
    
    func showErrorLine() {
        if cell.textView.text.isEmpty == true {
            cell.tipBottomLine.isHidden = false
            cell.tipBottomLine.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        }
    }
    
}
