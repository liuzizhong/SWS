//
//  SW_ConstructionAccessoriesFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/11.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_ConstructionAccessoriesFormViewController: SW_BaseFormViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    var isHideAddbtn = false {
        didSet {
            addBtn.isHidden = isHideAddbtn
        }
    }
    var header = ["配件编号","配件名称","数量","出库数量"]
    var items = [SW_RepairOrderAccessoriesModel]() {
        didSet {
            if items.count > 0 {
                spreadsheetView.isHidden = false
                let totalHeight = calculateCellHeight()
                spreadsheetView.frame = CGRect(x: 0, y: 40, width: SCREEN_WIDTH, height: max(totalHeight, SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 94 - TABBAR_BOTTOM_INTERVAL))
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(54 + TABBAR_BOTTOM_INTERVAL + spreadsheetView.frame.maxY))
                noDataLb.isHidden = true
            } else {
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 40))
            }
            spreadsheetView.reloadData()
        }
    }
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    var addBlock: NormalBlock?
    var addBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("增项", for: UIControl.State())
        btn.setTitleColor(UIColor.white, for: UIControl.State())
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.v2Color.blue
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(addBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    @objc private func addBtnClick(_ sender: UIButton) {
        addBlock?()
    }
    
    private func setup() {
        scrollView.addSubview(spreadsheetView)
        scrollView.addSubview(addBtn)
        addBtn.frame = CGRect(x: view.bounds.width - 71, y: 0, width: 56, height: 29)
//        spreadsheetView.isScrollEnabled = false
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    
    // MARK: DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
//        if column == 2 {
//            return 70
//        }
        return SCREEN_WIDTH/4
    }
    
    /// 记录上次计算d使用的width 相同则
    private var lastCalculateWidth: CGFloat = 0
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        let width = SCREEN_WIDTH/4
        for item in items {
            if let height = item.cellHeight, width == lastCalculateWidth {
                totalHeight += height
            } else {
                let cHeight = max(item.accessoriesNum.heightWithConstrainedWidth(width-15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(width, font: Font(16)) + 24)
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
            case header.count - 1:
                cell.setLabelAlignment(.right)
            default:
                cell.setLabelAlignment(.center)
            }
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            let model = items[indexPath.row - 1]
            switch indexPath.column {
            case 0:
                cell.isAdd = model.isAppend
                cell.isDel = model.isDel
                cell.setLabelAlignment(.left)
                cell.label.text = model.accessoriesNum
                if model.isDel {
                    cell.label.textColor =  UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = UIColor.v2Color.lightBlack
                }
                cell.label.numberOfLines = 0
            case 1:
                cell.isAdd = false
                cell.isDel = false
                cell.setLabelAlignment(.center)
                if model.isDel {
                    cell.label.textColor =  UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = UIColor.v2Color.lightBlack
                }
                cell.label.numberOfLines = 0
                cell.label.text = model.name
            case 2:
                cell.isAdd = false
                cell.isDel = false
                cell.setLabelAlignment(.center)
                if model.isDel {
                    cell.label.textColor =  UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = UIColor.v2Color.lightBlack
                }
                cell.label.text = model.saleCount.toAmoutString()
            default:
                cell.isAdd = false
                cell.isDel = false
                cell.setLabelAlignment(.right)
                if model.isDel {
                    cell.label.textColor =  UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = UIColor.v2Color.lightBlack
                }
                cell.label.text = model.outCount.toAmoutString()
            }
            return cell
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
}
