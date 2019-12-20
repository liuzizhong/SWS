//
//  SW_TipUpdateModalView.swift
//  SWS
//
//  Created by jayway on 2018/11/26.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_TipUpdateModalView: UIView {

    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var versionLb: UILabel!
    
    @IBOutlet weak var descLb: UILabel!
    
    @IBOutlet weak var bgContentView: UIView!
    
    @IBOutlet weak var updateBtn: SW_BlueButton!
    
    weak var modalVc: QMUIModalPresentationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgContentView.backgroundColor = UIColor.v2Color.blue
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    class func show(msg: String, currentVersion: String, isForce: Bool) {
        let modalView = Bundle.main.loadNibNamed("SW_TipUpdateModalView", owner: nil, options: nil)?.first as! SW_TipUpdateModalView
        modalView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        /// 强制更新不可以跳过
        modalView.skipBtn.isHidden = isForce
        modalView.versionLb.text = "v" + currentVersion
        modalView.descLb.text = msg
        
        MYWINDOW?.addSubview(modalView)
        modalView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        modalView.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        
        UIView.animate(withDuration: 0.5) {
            modalView.transform = CGAffineTransform.identity
        }
        
    }

    //MARK: -  按钮点击事件
    @IBAction func skipBtnClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func updateBtnClick(_ sender: UIButton) {
        UIApplication.shared.open(scheme: AppStoreLink)
    }
    
}
