//
//  SW_CustomerScoreViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerScoreViewController: UIViewController {
    
    private var items = [SW_CustomerScoreModel]()
    
    private var cellId = "CustomerScoreItemCellID"
    
    private var getScore: Double = 0
    
    private var isShowHeader = false
    
    lazy var sectionHeader: SW_CustomerScoreHeaderView = {
        let view = Bundle.main.loadNibNamed("SW_CustomerScoreHeaderView", owner: nil, options: nil)?.first as! SW_CustomerScoreHeaderView
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.registerNib(SW_CustomerScoreCell.self, forCellReuseIdentifier: self.cellId)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    
    init(_ items: [SW_CustomerScoreModel], isShowHeader: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.isShowHeader = isShowHeader
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(tableView)
        if isShowHeader {
            let header = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
            header.title = "回访记录"
            tableView.tableHeaderView = header
        }
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        glt_scrollView = tableView
        
        getScore = items.reduce(0) { (result, model) -> Double in
            return result + model.score
            }.roundTo(places: 1)
    }
    
    private func setupData() {
//        let model1 = SW_CustomerScoreModel(JSON.null)
//        model1.name = "我投诉这个人的服务态"
//        model1.totalScore = 30
//        model1.score = 20.5
//        items.append(model1)
//
//        let model2 = SW_CustomerScoreModel(JSON.null)
//        model2.name = "我投诉这个人的"
//        model2.totalScore = 30
//        model2.score = 10.2
//        items.append(model2)
//
//        let model3 = SW_CustomerScoreModel(JSON.null)
//        model3.name = "上帝"
//        model3.totalScore = 10
//        model3.score = 12.8
//        items.append(model3)
        
        
//        for i in 0...20 {
//            let temp = SW_CustomerScoreModel(JSON.null)
//            temp.name = "上帝"
//            temp.totalScore = 2
//            temp.score = 1.1
//            items.append(temp)
//        }
        
    }
    
}

extension SW_CustomerScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SW_CustomerScoreCell
        let item = items[indexPath.row]
        cell.item = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeader.getScoreLb.text = "得分(\(getScore.toAmoutString()))"
        return sectionHeader
    }
    
}

