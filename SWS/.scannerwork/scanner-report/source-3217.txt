//
//  SW_InvalidRemarkModalView.swift
//  SWS
//
//  Created by jayway on 2019/8/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_InvalidRemarkModalView: UIView{
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textView: QMUITextView!
    
    weak var modalVc: QMUIModalPresentationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        backgroundColor = .white
        layer.cornerRadius = 3
//        addShadow()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    class func show(_ content: String, title: String) {
        let modalView = Bundle.main.loadNibNamed("SW_InvalidRemarkModalView", owner: nil, options: nil)?.first as! SW_InvalidRemarkModalView
        modalView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 240)
        modalView.textView.text = content
        modalView.titleLabel.text = title
        
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
    
    @IBAction func sureBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
}
