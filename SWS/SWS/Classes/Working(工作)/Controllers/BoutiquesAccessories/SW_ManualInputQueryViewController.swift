//
//  SW_ManualInputQueryViewController.swift
//  SWS
//
//  Created by jayway on 2019/4/3.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ManualInputQueryViewController: FormViewController {
    
    private var resultBlock: ((String)->Void)?
    
    private var isRequesting = false
    private var code = ""
    
//    private var type: ProcurementType = .boutiques
//    private var purchaseOrderId: String = ""
//    private var supplier = ""
//    private var supplierId = ""
    
    init(_ resultBlock: ((String)->Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.resultBlock = resultBlock
//        self.purchaseOrderId = purchaseOrderId
//        self.type = type
//        self.supplier = supplier
//        self.supplierId = supplierId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
//    let customAllowedSet =  CharacterSet(charactersIn:"`%^{}\"[]|\\<> ").inverted
    /// 查询条形码相关信息
    private func queryCode(_ code: String) {
        resultBlock?(code)
    }
    
    
    //MARK: - Action
    private func formConfig() {
        //        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    private func createTableView() {
        /// 主要return  都刷新tableview
        defer {
            tableView.reloadData()
        }
        
        form = Form()
            +++
            Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "手动查询"
                }
                section.header = header
            }
            
            <<< SW_FieldButtonRow("code") {
                $0.rawTitle = NSLocalizedString("条码", comment: "")
                $0.buttonTitle = "查 询"
                $0.value = self.code
                $0.keyboardType = .asciiCapable
                $0.placeholder = "输入条码"
                $0.buttonActionBlock = { [weak self] in
                    if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
                    self?.queryCode(self?.code ?? "")
                }
                $0.cell.valueField.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.code = $0.value ?? ""
            }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
//    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
//
//    }
//
//    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
//
//    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
