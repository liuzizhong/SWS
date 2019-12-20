//
//  SW_MineViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/26.
//  Copyright © 2017年 yuanrui. All rights reserved.
//  [我的控制器] -> [SWS]

import UIKit


class SW_MineViewController: SW_TableViewController {

    let MineCellID = "MineCellID"
    
    var topView: SW_MineTopView!        //头部View
    var icons = [#imageLiteral(resourceName: "inform_uncollection"),#imageLiteral(resourceName: "me_icon_feedback"),#imageLiteral(resourceName: "Mine_Setting"),#imageLiteral(resourceName: "me_icon_aboutme")]               //图标数组
    var captions = [InternationStr("收藏"), InternationStr("反馈"),InternationStr("设置"),InternationStr("关于我们")]       //标题数组
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewToMineVc()    //设置子控件
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        isHideTabBar = false
    }
    
    //控制器显示调用方法
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -设置子控件
    func setupChildViewToMineVc() -> Void {
        //1.设置tableView
        tableView.snp.remakeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
        tableView.bounces = true
        tableView.backgroundColor = UIColor.white
        tableView.rowHeight = 64
        tableView.estimatedRowHeight = 64
        tableView.separatorStyle = .none
//        tableView.contentInset = UIEdgeInsetsMake(199, 0, 0, 0)
        tableView.register(SW_MineMainCell.self, forCellReuseIdentifier: MineCellID)
        topView = SW_MineTopView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 164+NAV_HEAD_INTERVAL))
        view.backgroundColor = .white
//        view.addSubview(topView)
        tableView.tableHeaderView = topView
        topView.messageModel = SW_UserCenter.shared.user
        topView.personInfoBlock = { [weak self] in
            //查看个人信息  push
            self?.navigationController?.pushViewController(SW_PersonalMessageViewController(), animated: true)
        }
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SW_MineMainCell = tableView.dequeueReusableCell(withIdentifier: MineCellID, for: indexPath) as! SW_MineMainCell
        cell.iconButton?.setImage(icons[indexPath.row], for: .normal)
        cell.captionLable?.text = captions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section,indexPath.row) {
        case (0,0):
//            if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_MineCollectionViewController") as? SW_MineCollectionViewController {
                navigationController?.pushViewController(SW_MineCollectionManagerController(), animated: true)
//            }
        case (0,1):
//            if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_FeedBackViewController") as? SW_FeedBackViewController {
                navigationController?.pushViewController(SW_FeedBackViewController(), animated: true)
//            }
        case (0,2):
            if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SettingViewController") as? SW_SettingViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        case (0,3):
            let vc = SW_CommonWebViewController(urlString: "https://www.yuanruiteam.com/mobile/aboutUs.html")
            vc.isShowTitle = false
            navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
}




