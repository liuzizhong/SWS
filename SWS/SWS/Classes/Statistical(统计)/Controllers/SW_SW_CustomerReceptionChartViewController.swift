//
//  SW_SW_CustomerReceptionChartViewController.swift
//  SWS
//
//  Created by jayway on 2018/9/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SW_CustomerReceptionChartViewController: UIViewController {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var countLb: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noDataView: UILabel!
    /// 数据源
    var datas = [SW_ReceptionChartDataModel]() {
        didSet {
            noDataView.isHidden = datas.count != 0
            theMax = datas.max(by: { return $0.count < $1.count })
            tableView.reloadData()
        }
    }
    
//    var colors = [UIColor]()
    
    private var theMax: SW_ReceptionChartDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PrintLog("didload")
        tableView.registerNib(SW_ProportionBarCell.self, forCellReuseIdentifier: "SW_ProportionBarCellID")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SW_SW_CustomerReceptionChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_ProportionBarCellID", for: indexPath) as! SW_ProportionBarCell
        guard datas.count > indexPath.row else { return cell }
        cell.barView.backgroundColor = datas[indexPath.row].color//colors[indexPath.row]//UIColor.getStatisticalChartColor(indexPath.row)
        cell.countLb.text = "\(datas[indexPath.row].count)人"
        if let theMax = theMax, theMax.count > 0, datas[indexPath.row].count > 0 {
            let proportion = Double(datas[indexPath.row].count) / Double(theMax.count)
            cell.barWidthConstraint.constant = max(1,(SCREEN_WIDTH - 100) * CGFloat(proportion))
        } else {
            cell.barWidthConstraint.constant = 1
        }
        return cell
    }
    
    
}
