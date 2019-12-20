//
//  SW_RepairBoardCell.swift
//  SWS
//
//  Created by jayway on 2019/6/11.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
//"repairOrderId": "ff8080816b4572ba016b458b043d0001",
//"repairOrderNum": "AW2019061157465973",
//"vin": "CJ001",
//"numberPlate": "粤L95555",
//"inStockDate": 1560239866874,
//"predictDate": 1560326189000,
//"afterSaleGroupList": [
//{
//"id": "ff8080816ad44a03016ad7f03f120020",
//"name": "2",
//"workingHoursTotal": 11,
//"balanceWorkingHours": 0
//},
//{
//"id": "402881ed6ad7dcf6016ad7e450fc0000",
//"name": "1",
//"workingHoursTotal": 11,
//"balanceWorkingHours": 0
//}
//]
class SW_RepairBoardCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noDataLb: UILabel!
    
    @IBOutlet weak var orderNumLb: UILabel!
    
    @IBOutlet weak var vinLb: UILabel!
    
    @IBOutlet weak var numberPlateLb: UILabel!
    
    @IBOutlet weak var inStockDateLb: UILabel!
    
    @IBOutlet weak var predictDateLb: UILabel!
    
    @IBOutlet weak var noDataBottomLb: UIView!
    
    var repairBoard: SW_RepairBoardModel? {
        didSet {
            guard let repairBoard = repairBoard else { return }
            orderNumLb.text = repairBoard.repairOrderNum
            vinLb.text =  repairBoard.vin.isEmpty ? "无" : repairBoard.vin
            numberPlateLb.text = repairBoard.numberPlate.isEmpty ? "无" : repairBoard.numberPlate
            inStockDateLb.text = repairBoard.inStockDateString
            predictDateLb.text = repairBoard.predictDateString
            
            tableViewHeightConstraint.constant = max(30.0, CGFloat(repairBoard.afterSaleGroupList.count) * 30.0)
            if repairBoard.afterSaleGroupList.count > 0 {
                noDataLb.isHidden = true
                noDataBottomLb.isHidden = true
            } else {
                noDataLb.isHidden = false
                noDataBottomLb.isHidden = false
            }
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        tableView.registerNib(SW_RepairBoardGroupCell.self, forCellReuseIdentifier: "SW_RepairBoardGroupCellID")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repairBoard?.afterSaleGroupList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_RepairBoardGroupCellID", for: indexPath) as! SW_RepairBoardGroupCell
        guard let repairBoard = repairBoard else { return cell }
        cell.model = repairBoard.afterSaleGroupList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}
