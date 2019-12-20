//
//  SW_WorkingViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/25.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkingViewController: UIViewController {
    
    private var items = [SW_NormalHomeCellModel]()
//    ,SW_NormalHomeCellModel(title: InternationStr("营收报表"), icon: #imageLiteral(resourceName: "work_icon_revenue"), pushVc: SW_RevenueManageViewController.self)
    
    private let imageW = (SCREEN_WIDTH - 45) / 2
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: imageW, height: imageW)
        flowLayout.minimumLineSpacing = 15
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.sectionInset = UIEdgeInsets(top: NAV_HEAD_INTERVAL + 50, left: 15, bottom: 0, right: 15)
        flowLayout.scrollDirection = .vertical
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        colView.delegate = self
        colView.dataSource = self
        colView.alwaysBounceVertical = true
        colView.showsHorizontalScrollIndicator = false
        colView.showsVerticalScrollIndicator = true
        colView.registerNib(SW_WorkingMainCell.self, forCellReuseIdentifier: "SW_WorkingMainCellID")
        return colView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        SW_BadgeManager.shared.getBadgeState()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    //setup
    private func setup() {
        isHideTabBar = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + SHOWACCESS_TABBAR_HEIGHT, right: 0)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        view.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.RedDotNotice, object: nil, queue: nil) {  [weak self]  (notifi) in
            self?.findItemBadge("工作报告", state: SW_BadgeManager.shared.workBadge.workModule)
            let repairOrderNotice = SW_BadgeManager.shared.repairOrderNotice
            self?.findItemBadge("维修接待管理", state: repairOrderNotice.repairNotice || repairOrderNotice.constructionNotice || repairOrderNotice.qualityNotice)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCheckAndUpdate, object: nil, queue: nil) { [weak self] (notification) in
            self?.setupItems()
        }
    }
    
    func setupItems() {
        items = [SW_NormalHomeCellModel(title: InternationStr("公告管理"), icon: #imageLiteral(resourceName: "work_icon_announcement"), pushVc: SW_InformManageViewController.self),SW_NormalHomeCellModel(title: InternationStr("工作报告"), icon: #imageLiteral(resourceName: "work_icon_workreport"), pushVc: SW_WorkReportMainViewController.self),SW_NormalHomeCellModel(title: InternationStr("共享资料"), icon: #imageLiteral(resourceName: "work_icon_shareddata"), pushVc: SW_DataShareViewController.self)]
        
        if let auth = SW_UserCenter.shared.user?.auth {
            if auth.carStockAuth.count > 0 {
                items.insert(SW_NormalHomeCellModel(title: InternationStr("车辆库存"), icon: #imageLiteral(resourceName: "work_icon_inventory"), pushVc: SW_CarStockListViewController.self), at: 3)
            }
            if auth.searchCarInfoAuth.count > 0 {
                items.insert(SW_NormalHomeCellModel(title: InternationStr("车辆查询"), icon: #imageLiteral(resourceName: "work_icon_inquire"), pushVc: SW_VehicleInfoQueryViewController.self), at: 3)
            }
            if auth.contractAuth.count > 0 {
                items.insert(SW_NormalHomeCellModel(title: InternationStr("销售合同管理"), icon: #imageLiteral(resourceName: "work_icon_contract"), pushVc: SW_SalesContractManagerViewController.self), at: 3)
            }
            
            if let accessoriesAuth = auth.accessoriesAuth.first {
                if accessoriesAuth.authDetails.count > 0 {
                    items.insert(SW_NormalHomeCellModel(title: InternationStr("配件管理"), icon: #imageLiteral(resourceName: "work_icon_accessories"), pushVc: SW_ProcurementListViewController.self), at: 3)
                }
            }
            if let boutiqueAuth = auth.boutiqueAuth.first {
                if boutiqueAuth.authDetails.count > 0 {
                    items.insert(SW_NormalHomeCellModel(title: InternationStr("精品管理"), icon: #imageLiteral(resourceName: "work_icon_boutique"), pushVc: SW_ProcurementListViewController.self), at: 3)
                }
            }
            
            if auth.repairAuth.count > 0 {
                items.insert(SW_NormalHomeCellModel(title: InternationStr("维修接待管理"), icon: #imageLiteral(resourceName: "work_icon_repairmanagement"), pushVc: SW_RepairOrderManagerViewController.self), at: 3)
            }
        }
        
        collectionView.reloadData()
        findItemBadge("工作报告", state: SW_BadgeManager.shared.workBadge.workModule)
        let repairOrderNotice = SW_BadgeManager.shared.repairOrderNotice
        findItemBadge("维修接待管理", state: repairOrderNotice.repairNotice || repairOrderNotice.constructionNotice || repairOrderNotice.qualityNotice)
    }
    
    /// 根据title设置红点状态
    private func findItemBadge(_ title: String, state: Bool) {
        if let index = self.items.firstIndex(where: { return $0.title == title }) {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SW_WorkingMainCell {
                cell.nameLb.badgeOffset = CGPoint(x: 4, y: 9)
                cell.nameLb.badgeView(state: state)
            }
        }
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension SW_WorkingViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_WorkingMainCellID", for: indexPath) as? SW_WorkingMainCell else {
            return UICollectionViewCell()
        }
        cell.imageView.image = items[indexPath.row].icon
        cell.nameLb.badgeView(state: false)
        cell.nameLb.text = items[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        switch items[indexPath.row].title {
        case "精品管理":
            navigationController?.pushViewController(SW_BoutiquesAccessoriesManagerViewController(.boutiques), animated: true)
        case "配件管理":
            navigationController?.pushViewController(SW_BoutiquesAccessoriesManagerViewController(.accessories), animated: true)
        default:
            navigationController?.pushViewController(items[indexPath.row].pushVc.init(), animated: true)
            break
        }
    }
    
}
