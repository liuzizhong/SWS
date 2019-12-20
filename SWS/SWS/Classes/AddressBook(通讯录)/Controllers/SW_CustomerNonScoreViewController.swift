//
//  SW_CustomerNonScoreViewController.swift
//  SWS
//
//  Created by jayway on 2019/7/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_CustomerNonScoreViewController: FormViewController {
    
    private var nonScoreItems = [SW_NonGradedItemsModel]()
    
    private var isShowHeader = false
    
    class func creatVc(_ nonScoreItems: [SW_NonGradedItemsModel], isShowHeader: Bool) -> SW_CustomerNonScoreViewController {
        let vc = SW_CustomerNonScoreViewController()
        vc.nonScoreItems = nonScoreItems
        vc.isShowHeader = isShowHeader
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        createTableView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        automaticallyAdjustsScrollViewInsets = false
        glt_scrollView = tableView
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
    }
    
    
    private func createTableView() {
        form = Form()
        
        if isShowHeader {
            form
            +++
                Eureka.Section() { section in
                    var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                    header.height = {70}
                    header.onSetupView = { view, _ in
                        view.title = "回访记录"
                    }
                    section.header = header
            }
        } else {
            form
            +++
                Eureka.Section(){ section in
                    var header = HeaderFooterView<UIView
                        >(.class)
                    header.height = {1}
                    header.onSetupView = { view, _ in
                        view.backgroundColor = .white
                    }
                    section.header = header
            }
        }
        
        for index in 0..<nonScoreItems.count {
            form.last!
                <<< SW_CommenLabelRow("nonScoreItems\(index)") {
                    $0.rawTitle = nonScoreItems[index].name
                    $0.allowsMultipleLine = true
                    $0.value = nonScoreItems[index].result
            }
        }
        
    }
    
    deinit {
        PrintLog("deinit")
    }
}
