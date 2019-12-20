//
//  SW_BaseFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/4.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BaseFormViewController: UIViewController {

    var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
//        if #available(iOS 11.0, *) {
//            sv.contentInsetAdjustmentBehavior = .never
//        }
        sv.backgroundColor = .white
        return sv
    }()
    
    var noDataLb: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.text = "暂无数据"
        lb.textColor = UIColor.v2Color.lightGray
        lb.font = Font(14)
        lb.backgroundColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(noDataLb)
        noDataLb.snp.makeConstraints { (make) in
            //            make.edges.equalToSuperview()
//            make.edges.equalTo(spreadsheetView)
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(80)
        }
        glt_scrollView = scrollView
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
