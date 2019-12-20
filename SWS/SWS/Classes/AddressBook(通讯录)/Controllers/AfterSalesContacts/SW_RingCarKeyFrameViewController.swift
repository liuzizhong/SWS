//
//  SW_RingCarKeyFrameViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/18.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RingCarKeyFrameViewController: UIViewController, QMUITextViewDelegate {

    @IBOutlet weak var textView: QMUITextView!
    
    @IBOutlet weak var tipLb: UILabel!
    
    var sureBlock: ((String)->Void)?
    
    var limitCount = 100
    
    class func creatVc(sureBlock: ((String)->Void)?) -> SW_RingCarKeyFrameViewController {
        let vc = SW_RingCarKeyFrameViewController(nibName: String(describing: SW_RingCarKeyFrameViewController.self), bundle: nil)
        vc.sureBlock = sureBlock
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "记录要点"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelBtnClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(sureBtnClick(_:)))
        textView.maximumTextLength = UInt(limitCount)
        tipLb.text = "0/\(limitCount)"
        textView.shouldResponseToProgrammaticallyTextChanges = false
        textView.delegate = self
        textView.becomeFirstResponder()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    @objc private func cancelBtnClick(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func sureBtnClick(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        sureBlock?(textView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tipLb.text = "\(textView.text.count)/\(limitCount)"
    }

    func textViewShouldReturn(_ textView: QMUITextView!) -> Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}



