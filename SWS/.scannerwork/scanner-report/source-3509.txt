//
//  SW_BarChartViewCell.swift
//  SWS
//
//  Created by jayway on 2018/8/1.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

class SW_BarChartViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: BarChartView!
    
    private var formatter = SW_BarChartAxisValueFormatter()
    
//    private var yFormatter: NumberFormatter = {
//        let format = NumberFormatter()
//        format.minimumIntegerDigits = 1
//        format.minimumFractionDigits = 0
//        format.maximumFractionDigits = 2
//        return format
//    }()
    
    private var marker: SW_BarChartXYMarkerView!
    
    private var colors = [UIColor]()
    private var legendLabels = [String]()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 9
        layout.interitemSpacing = 9
        layout.edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    var chartModel: SW_BarChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if chartModel != oldValue {
                titleLabel.text = chartModel.barChartTitle
                descriptionLabel.text = chartModel.unit
                legendLabels = chartModel.data.map({ return $0.amountName })
                marker.legendLabels = legendLabels
                formatter.legendLabels = legendLabels
                updateChartData(chartModel)
                collectionView.reloadData()
                self.layoutIfNeeded()
                //  easeInCirc easeInCubic easeInOutCubic easeInExpo
                chartView.animate(xAxisDuration: 2, yAxisDuration: 2, easingOption: .easeInCubic)
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
        
        chartView.rightAxis.enabled = false
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = true
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.legend.enabled = false
        chartView.xAxis.enabled = false
        chartView.noDataText = "暂无相关数据"
        chartView.noDataTextColor = UIColor.mainColor.gray
        
        chartView.highlightPerDragEnabled = false
//        chartView.highlightPerTapEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.mainColor.darkBlack
        leftAxis.labelFont = Font(8)
        leftAxis.drawGridLinesEnabled = true
//        leftAxis.gridAntialiasEnabled = false
//        leftAxis.granularityEnabled = true
        leftAxis.gridColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)

        leftAxis.axisLineColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        leftAxis.axisMinimum = 0
//        leftAxis.axisMinLabels = 2
//        leftAxis.labelCount = 10
//        leftAxis.forceLabelsEnabled = true
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: GlobalNumberFormatter)
        leftAxis.drawZeroLineEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.xAxis.valueFormatter = formatter
        
        marker = SW_BarChartXYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                      font: .systemFont(ofSize: 12),
                                      textColor: .white,
                                      insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                      xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }

    deinit {
        PrintLog("deinit")
    }
    
    func updateChartData(_ chartModel: SW_BarChartModel) {
        guard chartModel.data.count > 0 else {
            chartView.data = nil
            descriptionLabel.isHidden = true
            return
        }
        descriptionLabel.isHidden = false
        
        colors = []
        let yVals = (0..<chartModel.data.count).map { (i) -> BarChartDataEntry in
            colors.append(UIColor.getStatisticalChartColor(i))
            return BarChartDataEntry(x: Double(i+1), y: chartModel.data[i].amount)
        }
     
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            set1.colors = colors
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: nil)
            set1.colors = colors//ChartColorTemplates.material()
            set1.drawValuesEnabled = false
//            set1.valueTextColor = UIColor.mainColor.lightGray
//            set1.valueFormatter = DefaultValueFormatter(formatter: yFormatter)
            
            let data = BarChartData(dataSet: set1)
            
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 8)!)
            data.barWidth = 0.7
            chartView.data = data
        }
        chartView.highlightValue(nil)
        chartView.setVisibleXRangeMaximum(13)
        chartView.setVisibleXRangeMinimum(13)
    }
    
}

extension SW_BarChartViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
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

extension SW_BarChartViewCell: FixedSpacingCollectionLayoutDelegate {
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
//        return CGSize(width: FilterCollectionViewItemWidth, height: 20)
    }
    
}

extension SW_BarChartViewCell: ChartViewDelegate {
//    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//
//    }
//
//    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//
//    }
//
//    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
//
//    }
//
//    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
//
//    }
}
