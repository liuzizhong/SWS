//
//  SW_CustomerReceptionChartCell.swift
//  SWS
//
//  Created by jayway on 2018/9/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerReceptionChartCell: UITableViewCell {
    @IBOutlet weak var titleView: DNSPageTitleView!
    
    @IBOutlet weak var dnsContentView: DNSPageContentView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    private var pageStyle: DNSPageStyle = {
        let style = DNSPageStyle()
        style.isScaleEnable = true
        style.isShowBottomLine = true
        return style
    }()
    
    private var receptionController = SW_SW_CustomerReceptionChartViewController(nibName: String(describing: SW_SW_CustomerReceptionChartViewController.self), bundle: nil)
    
    private var retainedController = SW_SW_CustomerReceptionChartViewController(nibName: String(describing: SW_SW_CustomerReceptionChartViewController.self), bundle: nil)
    
    private var childViewControllers: [SW_SW_CustomerReceptionChartViewController] {
        return [receptionController,retainedController]
    }
    
    var chartModel: SW_CustomerReceptionChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if chartModel != oldValue {
                
                receptionController.view.backgroundColor = .white
                receptionController.titleLb.text = chartModel.dateString + "接访客户"
                receptionController.countLb.text = "\(chartModel.receptionTotal)人"
                receptionController.datas = chartModel.receptionDatas
                
                retainedController.view.backgroundColor = .white
                if let date = Date.dateWith(formatStr: "yyyy年MM月", dateString: chartModel.dateString) {
                    retainedController.titleLb.text = (date as NSDate).addingMonths(-1).stringWith(formatStr: "yyyy年MM月") + "留存客户"
                } else {
                    retainedController.titleLb.text = "留存客户"
                }
                retainedController.countLb.text = "\(chartModel.retainedTotal)人"
                retainedController.datas = chartModel.retainedDatas
                
                contentViewHeightConstraint.constant = CGFloat(30*chartModel.retainedDatas.count + 60)
                
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // 创建DNSPageStyle，设置样式
        
        // 设置标题内容
        let titles = ["接访客户", "留存客户"]
        
        // 设置默认的起始位置
        let startIndex = 0
        
        // 对titleView进行设置
        titleView.titles = titles
        titleView.style = pageStyle
        titleView.currentIndex = startIndex
        
        // 最后要调用setupUI方法
        titleView.setupUI()
        
        // 对contentView进行设置
        dnsContentView.childViewControllers = childViewControllers
        dnsContentView.startIndex = startIndex
        dnsContentView.style = pageStyle
        
        // 最后要调用setupUI方法
        dnsContentView.setupUI()
        
        // 让titleView和contentView进行联系起来
        titleView.delegate = dnsContentView
        dnsContentView.delegate = titleView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
