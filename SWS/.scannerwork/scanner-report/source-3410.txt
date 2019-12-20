//
//  SW_TextViewModalView.swift
//  SWS
//
//  Created by jayway on 2019/3/7.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_TextViewModalView: UIView, QMUITextViewDelegate {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var textView: QMUITextView!
    
    @IBOutlet weak var seperatorView: UIView!
    
    @IBOutlet weak var tipLb: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var sureBtn: SW_BlueButton!
    
    weak var modalVc: QMUIModalPresentationViewController?
    
    var sureBlock: ((String)->Void)?
    
    var limitCount: Int?
    
    /// 是否必须有值才能确定
    private var isShouldHadTextToDismiss = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        cancelBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.titleLabel?.font = Font(16)
        cancelBtn.layer.cornerRadius = 3.0
        cancelBtn.layer.masksToBounds = true
        textView.shouldResponseToProgrammaticallyTextChanges = false
        textView.delegate = self
        textView.becomeFirstResponder()
        backgroundColor = .white
        layer.cornerRadius = 3
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    class func show(title: String, placeholder: String, limitCount: Int? = nil, sureBlock: ((String)->Void)?, isShouldHadTextToDismiss: Bool = false) {
        let modalView = Bundle.main.loadNibNamed("SW_TextViewModalView", owner: nil, options: nil)?.first as! SW_TextViewModalView
        modalView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 300)
        modalView.titleLb.text = title
        modalView.textView.placeholder = placeholder
        modalView.limitCount = limitCount
        modalView.isShouldHadTextToDismiss = isShouldHadTextToDismiss
        if let limitCount = limitCount {
            modalView.textView.maximumTextLength = UInt(limitCount)
            modalView.tipLb.text = "0/\(limitCount)"
        } else {
            modalView.tipLb.isHidden = true
        }
        modalView.sureBlock = sureBlock
        
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let vc = QMUIModalPresentationViewController()
        modalView.modalVc = vc
        vc.dimmingView = dimmingView
        vc.animationStyle = .slide
        vc.contentView = modalView
        vc.supportedOrientationMask = .portrait
        vc.showWith(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
    @IBAction func sureBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        if isShouldHadTextToDismiss, textView.text.isEmpty {
            return
        }
        sureBlock?(textView.text)
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let limitCount = limitCount {
            self.tipLb.text = "\(textView.text.count)/\(limitCount)"
        }
        
    }
    
    func textViewShouldReturn(_ textView: QMUITextView!) -> Bool {
        return false
    }
}

