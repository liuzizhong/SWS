//
//  SW_InsuranceCompanyViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InsuranceCompanyViewController: SW_TableViewController {

    private var insuranceCompanys = [NormalModel]()
    
    var selectBlock: ((NormalModel)->Void)?
    
    private var bUnitId = 0
    
    init(_ bUnitId: Int?) {
        super.init(nibName: nil, bundle: nil)
        self.bUnitId = bUnitId ?? SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择保险公司"
        tableView.backgroundColor = UIColor.mainColor.background
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "insuranceCompanysCellID")
        requestData()
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestData() {
        SW_WorkingService.getInsuranceCompanys(bUnitId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.insuranceCompanys = json["list"].arrayValue.map({ return NormalModel($0) })
                let model = NormalModel()
                model.name = ""
                model.id = ""
                self.insuranceCompanys.insert(model, at: 0)
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insuranceCompanys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "insuranceCompanysCellID", for: indexPath)
        cell.textLabel?.font = Font(14)
        cell.textLabel?.textColor = UIColor.mainColor.darkBlack
        cell.textLabel?.text = insuranceCompanys[indexPath.row].name.isEmpty ? "取消" : insuranceCompanys[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectBlock?(insuranceCompanys[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
}
