//
//  SW_PrivacyPolicyModalView.swift
//  SWS
//
//  Created by jayway on 2018/11/27.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_PrivacyPolicyModalView: UIView {

    weak var modalVc: QMUIModalPresentationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
        layer.cornerRadius = 3
        addShadow()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    class func show() {
        let modalView = Bundle.main.loadNibNamed("SW_PrivacyPolicyModalView", owner: nil, options: nil)?.first as! SW_PrivacyPolicyModalView
        modalView.frame = CGRect(x: 0, y: 0, width: 275, height: 144)
        
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        let vc = QMUIModalPresentationViewController()
        modalView.modalVc = vc
        vc.dimmingView = dimmingView
        vc.animationStyle = .popup
        vc.contentView = modalView
        vc.supportedOrientationMask = .portrait
        vc.showWith(animated: true, completion: nil)
    }
    
    @IBAction func knowBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
}
