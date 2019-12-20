//
//  SW_AllInformMessageViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/21.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_AllInformMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索标题"
        return sbar
    }()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    private var keyword = ""
    
    /// 显示出来的keyword对应的数据。
    private var showInforms = [SW_InformModel]()
    
    /// 所以的公告数据
    private var informDatas = SW_DefaultConversations.getAllInformMsgAndSord()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKR: 初始化设置
    private func setup() {
        let  header = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
        header.title = "内部公告"
        tableView.tableHeaderView = header
        tableView.registerNib(SW_InformListCell.self, forCellReuseIdentifier: "SW_InformListCellID")
        self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
        self.tableView.ly_emptyView = self.emptyView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.keyboardDismissMode = .onDrag
        automaticallyAdjustsScrollViewInsets = false
        showInforms = informDatas
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40), scrollView: tableView)
        
        searchBar.backActionBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        searchBar.cancelActionBlock = { [weak self] in
            guard let self = self else { return }
            self.keyword = ""
            self.search()
        }
        searchBar.textChangeBlock = { [weak self] in
            guard let self = self else { return }
            if self.searchBar.searchText.isEmpty {
                self.keyword = ""
                self.search()
            }
        }
        
        searchBar.searchBlock = { [weak self] in
            guard let self = self else { return }
            self.keyword = self.searchBar.searchText
            self.search()
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
    }
    
    private func search() {
        
        if keyword.isEmpty {///
            showInforms = informDatas
        } else {
            
            showInforms = informDatas.filter({ (inform) -> Bool in
                return inform.title.contains(keyword)
            })
        }
        tableView.reloadData()
        if showInforms.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    //MARK: private method
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - tableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showInforms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_InformListCellID", for: indexPath) as! SW_InformListCell
        cell.model = showInforms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  SW_InformWebViewController(urlString: showInforms[indexPath.row].showUrl, informId: showInforms[indexPath.row].id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
