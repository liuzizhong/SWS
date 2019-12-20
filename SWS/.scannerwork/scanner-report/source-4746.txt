//
//  UICollectionGridViewController.swift
//  hangge_1081
//
//  Created by hangge on 2016/11/19.
//  Copyright © 2016年 hangge.com. All rights reserved.
//

import Foundation
import UIKit

//多列表格组件（通过CollectionView实现）
class UICollectionGridViewController: UICollectionViewController {
    //表头数据
    var cols: [String]! = []
    //行数据
    var rows: [[Any]]! = []
    //表格总个数
    var totalCount = 0
    
    var lastIndexPath: IndexPath?
    
    var popView: SW_ArrowPopLabel = {
        let view = SW_ArrowPopLabel(font: .systemFont(ofSize: 12),
                         textColor: .white,
                         insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        return view
    }()
    
    var colors = [UIColor]()
    //单元格内容居左时的左侧内边距
    private var cellPaddingLeft:CGFloat = 15
    
    init() {
        //初始化表格布局
        let layout = UICollectionGridViewLayout()
        super.init(collectionViewLayout: layout)
        layout.viewController = self
        collectionView!.backgroundColor = UIColor.white
//        collectionView!.register(UICollectionGridViewCell.self,
//                                      forCellWithReuseIdentifier: "cell")
        collectionView!.registerNib(UICollectionGridViewCell.self, forCellReuseIdentifier: "cell")
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.isDirectionalLockEnabled = true
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView!.bounces = false
        popView.tapBlock = { [weak self] in
            self?.popView.removeFromSuperview()
            self?.lastIndexPath = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("UICollectionGridViewController.init(coder:) has not been implemented")
    }
    
    //设置列头数据
    func setColumns(columns: [String]) {
        cols = columns
    }
    
    //添加行数据
    func addRow(row: [Any]) {
        rows.append(row)
        collectionView!.collectionViewLayout.invalidateLayout()
        collectionView!.reloadData()
    }
    
    func reloadData() {
        lastIndexPath = nil
        popView.removeFromSuperview()
        collectionView!.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        collectionView!.frame = CGRect(x:0, y:0,
                                width:view.frame.width, height:view.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //返回表格总行数
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if cols.isEmpty {
            return 0
        }
        //总行数是：记录数＋1个表头
        return rows.count + 1
    }
    
    //返回表格的列数
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return cols.count
    }
    
    //单元格内容创建
    override func collectionView(_ collectionView: UICollectionView,
                   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                    for: indexPath) as! UICollectionGridViewCell
        //第一列的内容左对齐，其它列内容居中
        if indexPath.row == 0 {
            cell.label.textAlignment = .left
            if !cols.isEmpty, indexPath.section > 0 {//第一列，不是表头，label显示图例
                cell.paddingLeft = 32
                cell.legendView.isHidden = false
                if colors.count > indexPath.section - 1 {
                    cell.legendView.backgroundColor = colors[indexPath.section - 1]
                } else {
                    cell.legendView.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.9215686275, blue: 1, alpha: 1)
                }
            } else {
                cell.legendView.isHidden = true
                cell.paddingLeft = cellPaddingLeft
            }
        } else {
            cell.legendView.isHidden = true
            cell.label.textAlignment = .center
            cell.paddingLeft = 0
        }
        if indexPath.section % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9843137255, blue: 1, alpha: 1)
        } else {
            cell.backgroundColor = .white
        }
        
        //设置列头单元格，内容单元格的数据
        if indexPath.section == 0 {
            let text = NSAttributedString(string: cols[indexPath.row], attributes: [
                .font: UIFont.boldSystemFont(ofSize: 13),
                .foregroundColor: UIColor.mainColor.gray
                ])
            cell.label.attributedText = text
        } else {
            cell.label.font = UIFont.systemFont(ofSize: 13)
            cell.label.textColor = UIColor.mainColor.darkBlack
            cell.label.text = "\(rows[indexPath.section-1][indexPath.row])"
        }
        
        return cell
    }
    
    //单元格选中事件
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        //打印出点击单元格的［行,列］坐标
        if indexPath.section != 0, indexPath.row == 0 {
            
            if lastIndexPath == indexPath {
                self.popView.removeFromSuperview()
                self.lastIndexPath = nil
            } else {
                let name = "\(rows[indexPath.section-1][0])"
                let percent = Double(rows[indexPath.section-1][1] as! Int) / Double(totalCount)
                var percentString = String(format: "%.2f%%", percent * 100)
                if totalCount == 0 {
                    percentString = "0.00%"
                }
                self.lastIndexPath = indexPath
                view.addSubview(popView)
                popView.label = name + ":" + percentString
                popView.position = collectionView.cellForItem(at: indexPath)!.origin
            }
        }
    }
}
