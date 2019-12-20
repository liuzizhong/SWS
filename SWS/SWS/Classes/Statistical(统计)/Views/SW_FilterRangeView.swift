//
//  SW_FilterRangeView.swift
//  SWS
//
//  Created by jayway on 2018/7/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

typealias SelectFilterRangeBlock = ((SW_FilterRegionModel?,SW_FilterUnitModel?,SW_FilterDeptModel?)->Void)

class SW_FilterRangeView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableContentView: UIStackView!
    
    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var tableView3: UITableView!
    
    @IBOutlet var tableViews: [UITableView]!
    
    @IBOutlet weak var buttonContentView: UIView!
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private var sureBlock: SelectFilterRangeBlock?
    
    private var cancelBlock: (()->Void)?
    
    private var allRegion = [SW_FilterRegionModel]()
    
    private var selectRegion: SW_FilterRegionModel? {
        didSet {
            if selectRegion != oldValue {
                selectUnit = nil
                selectDept = nil
                tableViews.forEach({ $0.reloadData() })
            }
        }
    }
    
    private var selectUnit: SW_FilterUnitModel? {
        didSet {
            if selectUnit != oldValue {
                selectDept = nil
                tableView2.reloadData()
                tableView3.reloadData()
            }
        }
    }
    
    private var selectDept: SW_FilterDeptModel? {
        didSet {
            if selectDept != oldValue {
                tableView3.reloadData()
            }
        }
    }
    
    private let reUseId = "SW_FilterRangeViewCellID"
    private var isHideDept = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableViews.forEach({
            $0.register(UITableViewCell.self, forCellReuseIdentifier: reUseId)
            $0.tableFooterView = UIView()
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            }
        })
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.cancelBlock?()
            self?.hide(timeInterval: FilterViewAnimationDuretion)
        }))
        tableViewHeight.constant = 390*AUTO_IPHONE6_HEIGHT_667
        tableContentView.isHidden = true
        buttonContentView.isHidden = true
        buttonContentView.addShadow()
    }
    
    func show(_ selectRegion: SW_FilterRegionModel?, selectUnit: SW_FilterUnitModel?, selectDept: SW_FilterDeptModel?, timeInterval: TimeInterval, onView: UIView, edgeInset: UIEdgeInsets = .zero, isAutoSelect: Bool = false, isHideDept: Bool = false, sureBlock: @escaping SelectFilterRangeBlock, cancelBlock: @escaping (()->Void)) {
        if superview != nil { return }
        
        onView.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.top.equalTo(edgeInset.top)
            make.leading.trailing.equalToSuperview()
        }
        onView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom)
            make.bottom.equalTo(-edgeInset.bottom)
            make.leading.equalTo(edgeInset.left)
            make.trailing.equalTo(-edgeInset.right)
        }
        onView.layoutIfNeeded()
        
        self.selectRegion = selectRegion
        self.selectUnit = selectUnit
        self.selectDept = selectDept
        self.sureBlock = sureBlock
        self.cancelBlock = cancelBlock
        self.isHideDept = isHideDept
        tableView3.isHidden = isHideDept
        
        UIView.animate(withDuration: timeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.tableContentView.isHidden = false
            self.buttonContentView.isHidden = isAutoSelect
            self.backgroundView.alpha = 1
        }, completion: nil)

        if allRegion.count == 0 {//如果没有分区数据，请求数据
            getRegionTreeData()
        } else {
            tableViews.forEach({ $0.reloadData() })
        }
    }
    
    func hide(timeInterval: TimeInterval) {
        if self.superview != nil {
            UIView.animate(withDuration: timeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.buttonContentView.isHidden = true
                self.tableContentView.isHidden = true
                self.backgroundView.alpha = 0
            }) { (finish) in
                self.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        hide(timeInterval: FilterViewAnimationDuretion)
        sureBlock?(selectRegion,selectUnit,selectDept)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        cancelBlock?()
        hide(timeInterval: FilterViewAnimationDuretion)
    }
    
    private func getRegionTreeData() {
        SW_AddressBookService.getRegionTree().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.allRegion = json.arrayValue.map({ return SW_FilterRegionModel($0) })
                self.tableViews.forEach({ $0.reloadData() })
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return allRegion.count + 1
        } else if tableView == tableView2 {
            return (selectRegion?.bUnitList.count ?? 0) + 1
        } else {
            return isHideDept ? 0 : (selectUnit?.deptList.count ?? 0) + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseId, for: indexPath)
        cell.textLabel?.font = Font(12)
        cell.backgroundColor = UIColor.white
        if tableView == tableView1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "全部"
                cell.textLabel?.textColor = selectRegion == nil ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
                cell.backgroundColor = selectRegion == nil ? UIColor.white : #colorLiteral(red: 0.9294117647, green: 0.9529411765, blue: 0.9764705882, alpha: 1)
            } else {
                cell.textLabel?.text = allRegion[indexPath.row-1].regionName
                cell.textLabel?.textColor = selectRegion == allRegion[indexPath.row-1] ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
                cell.backgroundColor = selectRegion == allRegion[indexPath.row-1] ? UIColor.white : #colorLiteral(red: 0.9294117647, green: 0.9529411765, blue: 0.9764705882, alpha: 1)
            }
        } else if tableView == tableView2 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "全部"
                cell.textLabel?.textColor = selectUnit == nil ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
            } else {
                cell.textLabel?.text = selectRegion!.bUnitList[indexPath.row-1].bUnitName
                cell.textLabel?.textColor = selectUnit == selectRegion!.bUnitList[indexPath.row-1] ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
            }
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "全部"
                cell.textLabel?.textColor = selectDept == nil ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
            } else {
                cell.textLabel?.text = selectUnit!.deptList[indexPath.row-1].deptName
                cell.textLabel?.textColor = selectDept == selectUnit!.deptList[indexPath.row-1] ? UIColor.mainColor.blue : UIColor.mainColor.darkBlack
            }
        }
        cell.contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        cell.textLabel?.snp.makeConstraints({ (make) in
            make.leading.equalTo(6)
            make.trailing.equalTo(-6)
            make.centerY.equalToSuperview()
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tableView1 {
            selectRegion = indexPath.row == 0 ? nil : allRegion[indexPath.row-1]
        } else if tableView == tableView2 {
            selectUnit = indexPath.row == 0 ? nil : selectRegion?.bUnitList[indexPath.row-1]
        } else {
            selectDept = indexPath.row == 0 ? nil : selectUnit?.deptList[indexPath.row-1]
        }
    }
    
}
