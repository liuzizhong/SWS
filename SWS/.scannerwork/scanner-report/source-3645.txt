//
//  SW_ComplaintsListViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

//1维修回访2购车回访3首次到店
enum HandleComplaintType: Int {
    case repairOrder = 1
    case purchaseCar
    case access
}

class SW_ComplaintsListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var isRequesting = false
    
    private var complaintsDatas = [SW_ComplaintsModel]()
    private var phone: String = ""
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    class func creatVc(_ complaints: [SW_ComplaintsModel], phone: String) -> SW_ComplaintsListViewController {
        let vc = UIStoryboard(name: "AddressBook", bundle: nil).instantiateViewController(withIdentifier: "SW_ComplaintsListViewController") as! SW_ComplaintsListViewController
        vc.complaintsDatas = complaints
        vc.phone = phone
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
        tableView.ly_emptyView = self.emptyView
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MAKR: 初始化设置
    private func setup() {
        let  header = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
        header.title = "客户投诉"
        tableView.tableHeaderView = header
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        automaticallyAdjustsScrollViewInsets = false
        
        if phone.isEmpty == false {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "personalcenter_icon_phone").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(phoneAction))
        }
    }
    
    //MARK: 请求收藏列表数据
    private func requsertcomplaintsDatas() {
//        SW_SuggestionService.getSuggestionList(SW_UserCenter.shared.user!.id).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
//            if let json = json as? JSON, error == nil {
//                self.complaintsDatas = json["list"].arrayValue.map({ (value) -> SW_ComplaintsModel in
//                    return SW_ComplaintsModel(value)
//                })
        
//                self.testData()
                self.tableView.reloadData()
//            } else {
//                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
//            }
//        })
    }
    
    //MARK: private method
    deinit {
        PrintLog("deinit")
    }
    
    private func testData() {
        let model1 = SW_ComplaintsModel(JSON.null)
        model1.content = "我投诉这个人的服务态度，太差劲了，不给我按摩捶背，一点不把我当上帝。差评！！！！"
        model1.createDate = Date().getCurrentTimeInterval()
        model1.replyDate = 0
        model1.replyContent = ""
        model1.auditState = .waitHandle
        complaintsDatas.append(model1)
        
        let model2 = SW_ComplaintsModel(JSON.null)
        model2.content = "我投诉这个人的服务态度，太差劲了，不给我按摩捶背，一点不把我当上帝。差评！！！！老子就是上帝"
        model2.createDate = Date().getCurrentTimeInterval()
        model2.replyDate = Date().getCurrentTimeInterval()
        model2.replyContent = "上帝个jio子，不理你"
        model2.auditState = .pass
        complaintsDatas.append(model2)
        
        let model3 = SW_ComplaintsModel(JSON.null)
        model3.content = "我投诉这个人的服务态度，太差劲了，不给我按摩捶背，一点不把我当上帝。差评！！！！老子就是上帝"
        model3.createDate = Date().getCurrentTimeInterval()
        model3.replyDate = Date().getCurrentTimeInterval()
        model3.replyContent = "上帝个jio子，不理你,傻逼."
        model3.auditState = .rejected
        complaintsDatas.append(model3)
    }
    
    @objc private func phoneAction() {
//        if user.phoneNum1.isEmpty == false {
            UIApplication.shared.open(scheme: "tel://\(phone)")//
//        }
    }
    
    //MARK: - tableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complaintsDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_ComplaintsListCellID", for: indexPath) as! SW_ComplaintsListCell
        cell.model = complaintsDatas[indexPath.row]
        cell.dealBlock = { [weak self] in
            SW_TextViewModalView.show(title: "处理反馈", placeholder: "输入处理反馈", limitCount: 300, sureBlock: { [weak self] (text) in
                guard let self = self else { return }
                guard !self.isRequesting else { return }
                self.isRequesting = true
                SW_AfterSaleService.handleComplaint(self.complaintsDatas[indexPath.row].id, feedback: text).response({ (json, isCache, error) in
                    if let _ = json as? JSON, error == nil {
                        /// 处理成功，刷新页面
                        showAlertMessage("处理成功", MYWINDOW)
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, userInfo: ["complaintType": self.complaintsDatas[indexPath.row].complaintType, "orderId": self.complaintsDatas[indexPath.row].orderId])
                        self.complaintsDatas[indexPath.row].replyContent = text
                        self.complaintsDatas[indexPath.row].replyDate = Date().getCurrentTimeInterval()
                        self.complaintsDatas[indexPath.row].auditState = .waitAudit
                        tableView.reloadRow(at: indexPath, with: .automatic)
//                        self.navigationController?.popViewController(animated: true)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    self.isRequesting = false
                })
            }, isShouldHadTextToDismiss: true)
            
        }
        return cell
    }
    
}

