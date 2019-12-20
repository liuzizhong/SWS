//
//  SW_PieChartViewCell.swift
//  SWS
//
//  Created by jayway on 2018/9/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

class SW_PieChartViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: PieChartView!
    
    private var colors = [UIColor]()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 0
        layout.interitemSpacing = 0
        layout.edgeInset = UIEdgeInsets(top: 1, left: 15, bottom: 1, right: 15)
        return layout
    }()
    
    var chartModel: SW_PieChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if chartModel != oldValue {
                titleLabel.text = chartModel.pieChartTitle
                updateChartData(chartModel)
                collectionView.reloadData()
                self.layoutIfNeeded()
                //  easeInCirc easeInCubic easeInOutCubic easeInExpo
//                chartView.animate(xAxisDuration: 1.2, easingOption: .easeOutBack)
                
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        collectionView.collectionViewLayout = flowLayout
        collectionView.registerNib(SW_LikeCarLegendCell.self, forCellReuseIdentifier: "SW_LikeCarLegendCellID")
        
//        chartView.delegate = self
        
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
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 230
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        
//        chartView.entryLabelColor = .white
//        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        
//        chartView.drawEntryLabelsEnabled = !chartView.drawEntryLabelsEnabled
//        chartView.usePercentValuesEnabled = !chartView.usePercentValuesEnabled
//        chartView.drawHoleEnabled = !chartView.drawHoleEnabled
//        chartView.drawCenterTextEnabled = !chartView.drawCenterTextEnabled
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    func updateChartData(_ chartModel: SW_PieChartModel) {
        guard chartModel.data.count > 0 else {
            chartView.data = nil
            return
        }
        
        colors = []
        let entries = (0..<chartModel.data.count).map { (i) -> PieChartDataEntry in
            colors.append(UIColor.getStatisticalChartColor(i))
            return PieChartDataEntry(value: chartModel.data[i].value)
        }
        
        let set = PieChartDataSet(values: entries, label: "客户意向")
        set.drawIconsEnabled = false
        //        set.sliceSpace = 2
        set.colors = colors
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "客户意向\n\(chartModel.total)人")
        centerText.setAttributes([.font : MediumFont(14),
                                  .foregroundColor : UIColor.mainColor.darkBlack,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText
        
        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.5
        set.valueLinePart2Length = 0.6
        //set.xValuePosition = .outsideSlice
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

extension SW_PieChartViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chartModel?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_LikeCarLegendCellID", for: indexPath) as! SW_LikeCarLegendCell
        cell.legendColor.backgroundColor = colors[indexPath.row]
        cell.legendName.text = chartModel?.data[indexPath.row].name
        let text = "\(Int(chartModel?.data[indexPath.row].value ?? 0))人"
        cell.peopleCountLb.text = text
        cell.peopleLbWidthConstraint.constant = text.size(cell.peopleCountLb.font, width: 0).width + 20
        return cell
    }
    
}

extension SW_PieChartViewCell: FixedSpacingCollectionLayoutDelegate {
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
        //        if size.height != flowLayout.edgeInset.bottom {
        collectionViewHeight.constant = size.height
        //        }
    }
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
//        guard let legends = chartModel?.data else { return CGSize.zero }
//        guard  legends.count > indexPath.row else { return CGSize.zero }
//        let string = legends[indexPath.row].name
        let maxW = collectionView.bounds.size.width - 30
//        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(12)])
        return CGSize(width: maxW, height: 30)
        //        return CGSize(width: FilterCollectionViewItemWidth, height: 20)
    }
    
}


