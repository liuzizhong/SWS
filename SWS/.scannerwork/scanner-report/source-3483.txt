//
//  SW_CustomerAccessTypeCardCell.swift
//  SWS
//
//  Created by jayway on 2018/9/12.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

class SW_CustomerAccessTypeCardCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var chartView: PieChartView!
    
    private var gridViewController = UICollectionGridViewController()
    
    private var colors = [UIColor]()
    
    var cardType = AccessTypeChartType.reception
    
    var lastType: AccessTypeChartType?
    
    var chartModel: SW_CustomerAccessTypeChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if lastType != cardType || chartModel != oldValue {//cell 复用
                lastType = cardType
                
                titleLb.text = chartModel.dateString + cardType.rawTitle + "统计"
//                colors = chartModel.colors
                updateChartData(chartModel)
                
                gridViewController.view.isHidden = chartModel.accessTypeDatas.count == 0
                gridViewController.totalCount = chartModel.getValue(cardType)
                gridViewController.rows = []
                gridViewController.colors = colors
                gridViewController.setColumns(columns: chartModel.getColumns(cardType))
                gridViewController.rows = chartModel.getRows(cardType)
                gridViewController.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.cornerRadius = 3
        addShadow()//设置阴影的偏移量
        
        chartView.legend.enabled = false
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58//空心位置占比
        chartView.transparentCircleRadiusPercent = 0.61//浅色部分占比
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        chartView.drawCenterTextEnabled = true
        chartView.noDataText = "暂无相关数据"
        chartView.noDataTextColor = UIColor.mainColor.gray
        chartView.drawEntryLabelsEnabled = false
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 230
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        
        addSubview(gridViewController.view)
        gridViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(chartView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    func updateChartData(_ chartModel: SW_CustomerAccessTypeChartModel) {
        guard chartModel.accessTypeDatas.count > 0 else {
            chartView.data = nil
            return
        }
        
        colors = []
        
        var entries = (0..<chartModel.accessTypeDatas.count).map { (i) -> PieChartDataEntry in
            colors.append(chartModel.accessTypeDatas[i].color)
            return PieChartDataEntry(value: Double(chartModel.accessTypeDatas[i].getValue(cardType)))
        }
        /// 找出数据中的最大值
        let max = entries.max(by: { return $0.value < $1.value })
        if max?.value == 0 {//当全部都是0时，添加一个1的值，确保圆形能画出来
            colors.append(#colorLiteral(red: 0.8352941176, green: 0.9215686275, blue: 1, alpha: 1))
            entries.append(PieChartDataEntry(value: 1))
        }
        let set = PieChartDataSet(values: entries, label: cardType.rawTitle)
        set.drawIconsEnabled = false
        set.colors = colors
        
        set.drawValuesEnabled = max?.value != 0
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "\(cardType.rawTitle)\n\(chartModel.getValue(cardType))人")
        centerText.setAttributes([.font : MediumFont(14),
                                  .foregroundColor : UIColor.mainColor.darkBlack,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText
        
        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.5
        set.valueLinePart2Length = 0.6
//        set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(UIColor.mainColor.darkBlack)
        
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
}
