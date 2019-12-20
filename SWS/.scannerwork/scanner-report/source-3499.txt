//
//  SW_CustomerLineChartViewCell.swift
//  SWS
//
//  Created by jayway on 2018/9/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

typealias SelectDateBlock = (DateType,String,Int)->Void

class SW_CustomerLineChartViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: LineChartView!
    
    private var colors = [UIColor]()
    private var legendLabels = [String]()
    
    var selectDateBlock: SelectDateBlock?
    
    private var xFormatter: SW_DateAxisValueFormatter!
    //    private var yFormatter: NumberFormatter = {
    //        let format = NumberFormatter()
    //        format.minimumIntegerDigits = 1
    //        format.minimumFractionDigits = 0
    //        format.maximumFractionDigits = 2
    //        return format
    //    }()
    
    private var marker: SW_LineChartXYMarkerView!
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 9
        layout.interitemSpacing = 9
        layout.edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    var chartModel: SW_CustomerLineChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if chartModel != oldValue {
                titleLabel.text = chartModel.lineChartTitle
                descriptionLabel.text = chartModel.unit
//                colors = chartModel.colors
                updateChartData(chartModel)
                collectionView.reloadData()
                self.layoutIfNeeded()
                chartView.animate(xAxisDuration: 2, easingOption: .easeInCubic)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        collectionView.collectionViewLayout = flowLayout
        collectionView.registerNib(SW_LegendCollectionViewCell.self, forCellReuseIdentifier: "SW_LegendCollectionViewCellID")
        
        chartView.delegate = self
        
        //        chartView.doubleTapToZoomEnabled = true
        //        chartView.setScaleEnabled(true)
        
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.setScaleEnabled(false)
        chartView.highlightPerDragEnabled = false
        //        chartView.highlightPerTapEnabled = false
        chartView.legend.enabled = false
        chartView.noDataText = "暂无相关数据"
        chartView.noDataTextColor = UIColor.mainColor.gray
        chartView.rightAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = Font(13)
        xAxis.labelTextColor = UIColor.mainColor.darkBlack
        xAxis.drawAxisLineEnabled = true
        xAxis.labelPosition = .bottom
        xFormatter = SW_DateAxisValueFormatter(chart: chartView)
        xAxis.valueFormatter = xFormatter
        
        //轴线设置
        xAxis.axisLineColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        xAxis.axisLineWidth = 1
        ///x轴的网格竖线 使用 虚线  属性
        xAxis.gridLineDashLengths = [3,3]
        xAxis.gridLineWidth = 1
        xAxis.gridColor =  #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.mainColor.darkBlack
        leftAxis.labelFont = Font(8)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        //轴线设置
        leftAxis.axisLineColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        leftAxis.axisLineWidth = 1
        leftAxis.axisLineDashLengths = [3,3]
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: GlobalNumberFormatter)
        
        marker = SW_LineChartXYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                          font: .systemFont(ofSize: 12),
                                          textColor: .white,
                                          insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    func updateChartData(_ chartModel: SW_CustomerLineChartModel) {
        //取出图表中线的个数 最少要1条  //x轴坐标个数最少1个
        guard chartModel.data.count > 0,
            var dataSetCount = chartModel.data.first?.value.count,
            dataSetCount > 0  else {
                descriptionLabel.isHidden = true
                legendLabels = []
                chartView.data = nil
                return
        }
        //取前8条数据展示
        dataSetCount = min(8, dataSetCount)
        
        descriptionLabel.isHidden = false
        
        legendLabels = []
        colors = []
        
        var dataSets = [LineChartDataSet]()
        //创建N条线
        for i in 0..<dataSetCount {
            //获取这条线的所有数据
            let yVals = (0..<chartModel.data.count).map { (x) -> ChartDataEntry in
                var y: Double
                if chartModel.data[x].value.count > i {
                    y = Double(chartModel.data[x].value[i].count)
                } else {
                    y = 0
                }
                return ChartDataEntry(x: Double(x), y: y)//这里的y要可变
            }

            legendLabels.append(chartModel.data[0].value[i].name)
            colors.append(chartModel.data[0].value[i].color)
            
            let set = LineChartDataSet(values: yVals, label: nil)
            set.axisDependency = .left
            set.mode = .linear
            let color = UIColor.getStatisticalChartColor(i)
            
            set.setColor(colors[i])
            set.drawCirclesEnabled = true
            set.drawValuesEnabled = false
            set.lineWidth = 2
            set.setCircleColor(color)
            set.circleRadius = 3
            set.highlightColor = UIColor.mainColor.blue//UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
            set.drawCircleHoleEnabled = false
            dataSets.append(set)
        }
        
        let data = LineChartData(dataSets: dataSets)
        
        xFormatter.dateType = chartModel.dateType
        switch chartModel.dateType {
        case .day:
            chartView.xAxis.axisMaximum = Double(chartModel.days-1)//计算当前月份天数
            chartView.xAxis.axisMinimum = 0
        case .month:
            chartView.xAxis.axisMaximum = 11
            chartView.xAxis.axisMinimum = 0
        case .year:
            xFormatter.labels = chartModel.data.map({ return $0.label })
            chartView.xAxis.axisMaximum = Double(chartModel.data.count) - 1
            chartView.xAxis.axisMinimum = 0
        }
        
        chartView.data = data
        chartView.highlightValue(nil)
        
        let count = min(10, Int(chartView.xAxis.axisMaximum))
        chartView.xAxis.labelCount = count//min(10, Int(chartView.xAxis.axisMaximum))
        chartView.setVisibleXRangeMaximum(10)
        chartView.setVisibleXRangeMinimum(Double(count))
    }
    
    
}

extension SW_CustomerLineChartViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return legendLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_LegendCollectionViewCellID", for: indexPath) as! SW_LegendCollectionViewCell
        cell.legendColor.backgroundColor = colors[indexPath.row]
        cell.legendName.text = legendLabels[indexPath.row]
        return cell
    }
    
}

extension SW_CustomerLineChartViewCell: FixedSpacingCollectionLayoutDelegate {
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
        //        if size.height != flowLayout.edgeInset.bottom {
        collectionViewHeight.constant = size.height
        //        }
    }
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        guard  legendLabels.count > indexPath.row else { return CGSize.zero }
        let string = legendLabels[indexPath.row]
        let maxW = collectionView.bounds.size.width - 30
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(12)])
        return CGSize(width: min(textSize.width + 26, maxW), height: 13)
        //        return CGSize(widt h: FilterCollectionViewItemWidth, height: 20)
    }
    
}

extension SW_CustomerLineChartViewCell: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let chartModel = chartModel else { return }
//
        var dateString = chartModel.dateString
        if chartModel.dateType == .year {
            dateString = xFormatter.labels[Int(highlight.x)]
        }
        selectDateBlock?(chartModel.dateType,dateString,Int(highlight.x))
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        PrintLog("chartValueNothingSelected")
    }
    
}
