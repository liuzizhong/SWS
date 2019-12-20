//
//  SW_SelectRevenueReportTypeTableViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectRevenueReportTypeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(SW_EditDayOrderViewController(), animated: true)
        case 1:
            self.navigationController?.pushViewController(SW_EditDayNonOrderViewController(), animated: true)
        case 2:
            self.navigationController?.pushViewController(SW_EditYearNonOrderViewController(type: .monthNonOrder), animated: true)
        case 3:
            self.navigationController?.pushViewController(SW_EditYearNonOrderViewController(type: .yearNonOrder), animated: true)
        default:
            break
        }
    }
    }
