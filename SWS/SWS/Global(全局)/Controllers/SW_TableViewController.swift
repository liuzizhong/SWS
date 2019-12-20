//
//  SW_TableViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/26.
//  Copyright © 2017年 yuanrui. All rights reserved.
//  [自定义TableViewController] -> [SWS]

import UIKit

class SW_TableViewController: SW_BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let TableViewCellID = "TableViewCellID"
    var caption: String?        //标题文字
    
    var tableView = UITableView.init(frame: .zero, style: .plain) //tableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        } else {
//            // Fallback on earlier versions
//        }
        creatChildViewToTableVc()
 
    }
    //创建子控件
    func creatChildViewToTableVc() -> Void {
        //1.创建子控件
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedRowHeight = 0
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) -> Void in
            make.edges.equalToSuperview()
//            make.left.right.equalToSuperview()
//            make.top.equalToSuperview().offset(NAV_TOTAL_HEIGHT)
//            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM_INTERVAL - TABBAR_HEIGHT)
        })
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TableViewCellID)
        tableView.backgroundColor = UIColor.white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellID, for: indexPath)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     禁止具体某个viewController的旋转
     */
    open override var shouldAutorotate : Bool {
//        if isIPad {//  ???  ipad  才旋转？？
//            return super.shouldAutorotate
//        } else {
            return true
//        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if isIPad {
//            return .all
//        } else {
            return .portrait
//        }
    }
}
