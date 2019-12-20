//
//  SW_InformReadRecordViewController.swift
//  SWS
//
//  Created by jayway on 2019/7/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_InformReadRecordViewController: UIViewController {
    
    private let rangeCellId = "SW_ReadRecordCellId"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        //        if #available(iOS 11.0, *) {
        //            tableView.contentInsetAdjustmentBehavior = .never
        //        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        tableView.registerNib(SW_ReadRecordListCell.self, forCellReuseIdentifier: self.rangeCellId)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    private var informId = 0
    
    private var currentList = [SW_ReadRecordStaffModel]()
    
    init(_ informId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.informId = informId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListAndReload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupView() {
        navigationItem.title = "阅读记录"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView)
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - 网络请求
    
    /// 获取当前页面的数据
    ///
    /// - Parameter
    private func getListAndReload() {
        SW_WorkingService.getInformReadRecord(informId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.currentList = json["list"].arrayValue.map({ SW_ReadRecordStaffModel($0) })
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "未读(\(self.currentList.filter({ return !$0.isRead }).count))", style: .plain, target: self, action: #selector(self.noReadAction(_:)))
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.v2Color.lightGray,NSAttributedString.Key.font: Font(16)], for: .normal)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    @objc private func noReadAction(_ btn: UIBarButtonItem) {
        
    }
    
}

extension SW_InformReadRecordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_ReadRecordListCell
        let model = currentList[indexPath.row]
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

