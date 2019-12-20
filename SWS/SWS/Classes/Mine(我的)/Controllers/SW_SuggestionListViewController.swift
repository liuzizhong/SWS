//
//  SW_SuggestionListViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/10.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SuggestionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var suggestionDatas = [SW_SuggestionModel]()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertSuggestionDatas()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MAKR: 初始化设置
    private func setup() {
        let  header = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        header.title = "我的反馈"
        tableView.tableHeaderView = header
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    //MARK: 请求收藏列表数据
    private func requsertSuggestionDatas() {
        SW_SuggestionService.getSuggestionList(SW_UserCenter.shared.user!.id).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.suggestionDatas = json["list"].arrayValue.map({ (value) -> SW_SuggestionModel in
                    return SW_SuggestionModel(value)
                })
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    //MARK: private method
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - tableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_SuggestionListCellID", for: indexPath) as! SW_SuggestionListCell
        cell.model = suggestionDatas[indexPath.row]
        return cell
    }

}
