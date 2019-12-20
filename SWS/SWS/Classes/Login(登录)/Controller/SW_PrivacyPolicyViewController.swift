//
//  SW_PrivacyPolicyViewController.swift
//  SWS
//
//  Created by jayway on 2018/11/27.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var privacyPolicyLb: UILabel!
    
    @IBOutlet weak var notAgreedBtn: QMUIButton!
    
    @IBOutlet weak var agreedBtn: SW_BlueButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notAgreedBtn.layer.cornerRadius = 3
        notAgreedBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        notAgreedBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
        notAgreedBtn.layer.borderWidth = 1
        
        let attrText = NSMutableAttributedString(string: "如您同意《效率+隐私政策》请点击“同意”开始使用我们的产品和服务，我们尽全力保护您的个人信息安全")
        attrText.setAttributes([.foregroundColor : UIColor.v2Color.blue], range: NSRange(location: 4, length: 9))
        privacyPolicyLb.attributedText = attrText
        
        privacyPolicyLb.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
            let vc = SW_CommonWebViewController(urlString: "https://www.yuanruiteam.com/mobile/policy.html")
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    
    @IBAction func notAgreedBtnClick(_ sender: QMUIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        SW_PrivacyPolicyModalView.show()
    }
    
    @IBAction func agreedBtnClick(_ sender: SW_BlueButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        UserDefaults.standard.set(true, forKey: "isAgreedPrivacyPolicy")
        UserDefaults.standard.synchronize()
        
        dismiss(animated: true, completion: nil)
    }
    
    /// 检查是否同意过隐私政策，没同意就显示
    static func checkAgreedPrivacyPolicyAndShow(_ controller: UIViewController) {
        let isAgreed = UserDefaults.standard.bool(forKey: "isAgreedPrivacyPolicy")
        
        guard !isAgreed else { return }/// 没同意
        
       let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_PrivacyPolicyViewController") as! SW_PrivacyPolicyViewController
        MYWINDOW?.endEditing(true)
        let nav = SW_NavViewController.init(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        controller.present(nav, animated: true, completion: nil)
    }
}
