//
//  SW_InformMessageViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InformMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    private var type = InformType.group

    private var informList = [SW_InformModel]()
    
    private lazy var emptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "暂无数据", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.mainColor.lightGray
        return emptyView!
    }()
    
    class func ctreatVc(_ type: InformType) -> SW_InformMessageViewController {
        let vc = UIStoryboard(name: "Message", bundle: nil).instantiateViewController(withIdentifier: "SW_InformMessageViewController") as! SW_InformMessageViewController
        vc.type = type
        vc.getInformList()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func setup() {
//        tableView.selecstyp = .none
        navigationItem.title = type.rawTitle
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.ly_emptyView = emptyView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.reloadData()
        scroolToBottom()
    }

    private func getInformList() {
        informList = SW_DefaultConversations.getInform(type)
    }
    
    private func scroolToBottom() {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        if informList.count > 0 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: self.informList.count - 1, section: 0), at: .top, animated: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard informList.count > indexPath.row else { return UITableViewCell() }
        let model = informList[indexPath.row]
        if let _ = URL(string: model.coverImg) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformDetailTableViewCellID", for: indexPath) as! SW_InformDetailTableViewCell
            cell.type = type
            cell.model = model
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformNoCoverCellID", for: indexPath) as! SW_InformNoCoverCell
            cell.type = type
            cell.model = model
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  SW_InformWebViewController(urlString: informList[indexPath.row].showUrl, informId: informList[indexPath.row].id)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    deinit {
        PrintLog("deinit")
    }
}
