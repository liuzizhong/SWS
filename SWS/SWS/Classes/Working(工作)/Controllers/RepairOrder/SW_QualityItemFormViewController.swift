//
//  SW_QualityItemFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/6.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView
import SevenSwitch

class SW_QualityItemFormViewController: SW_BaseFormViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    var header = ["项目编号","项目名称","工时","是否合格"]
    var items = [SW_RepairOrderItemModel]() {
        didSet {
            if items.count > 0 {
                spreadsheetView.isHidden = false
                let totalHeight = calculateCellHeight()
                spreadsheetView.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: max(totalHeight, SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 94 - TABBAR_BOTTOM_INTERVAL))
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(74 + TABBAR_BOTTOM_INTERVAL + spreadsheetView.frame.height))
                noDataLb.isHidden = true
            } else {
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 40))
            }
            spreadsheetView.reloadData()
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        }
    }
    
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
        scrollView.addSubview(spreadsheetView)
//        spreadsheetView.frame = view.bounds
//        scrollView.contentSize = view.bounds.size
        spreadsheetView.isScrollEnabled = true
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.register(FormSwitchCell.self, forCellWithReuseIdentifier: String(describing: FormSwitchCell.self))
    }
    
    // MARK: DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return SCREEN_WIDTH/CGFloat(header.count)
    }
    
    /// 记录上次计算d使用的width 相同则
    private var lastCalculateWidth: CGFloat = 0
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        let width = SCREEN_WIDTH/CGFloat(header.count) - 15
        for item in items {
            if let height = item.cellHeight, width == lastCalculateWidth {
                totalHeight += height
            } else {
                let cHeight = max(item.repairItemNum.heightWithConstrainedWidth(width, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(SCREEN_WIDTH/CGFloat(header.count), font: Font(16)) + 24)
                let textH = max(44, cHeight)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        lastCalculateWidth = width
        return totalHeight + 35
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]
            switch indexPath.column {
            case 0:
                cell.setLabelAlignment(.left)
            case 1,2:
                cell.setLabelAlignment(.center)
            default:
                cell.setLabelAlignment(.right)
            }
            return cell
        } else {
            let model = items[indexPath.row - 1]
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.left)
                cell.label.text = model.repairItemNum
                cell.label.numberOfLines = 0
                return cell
            case 1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                cell.label.text = model.name
                cell.label.numberOfLines = 0
                return cell
            case 2:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                cell.label.text = model.workingHours.toAmoutString()
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: FormSwitchCell.self), for: indexPath) as! FormSwitchCell
                cell.switchView.on = model.isQualified
                cell.valueChangeBlock = { (isOn) in
                    model.isQualified = isOn
                }
                return cell
            }
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
}


class FormSwitchCell: Cell {
    
    let switchView = SevenSwitch()
    
    var valueChangeBlock: ((Bool)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        switchView.onLabel.text = "Yes"
        switchView.onLabel.textColor = .white
        switchView.onLabel.font = Font(10)
        switchView.offLabel.text = "No"
        switchView.offLabel.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        switchView.offLabel.font = Font(10)
        switchView.onTintColor = UIColor.v2Color.blue
        switchView.borderColor = UIColor.v2Color.separator
        
        switchView.addTarget(self, action: #selector(valueChangeAction(_:)), for: .valueChanged)
        
        contentView.addSubview(switchView)
        switchView.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(27)
            make.width.equalTo(50)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func valueChangeAction(_ sender: SevenSwitch) {
        valueChangeBlock?(sender.on)
    }
}
