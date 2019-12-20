//
//  SW_DateAxisValueFormatter.swift
//  SWS
//
//  Created by jayway on 2018/8/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

class SW_DateAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    var labels = [String]()
    
    var dateType = DateType.day
    
    weak var chart: BarLineChartViewBase?
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch dateType {
        case .day:
            return "\(Int(value) + 1)日"
        case .month:
            return "\(Int(value) + 1)月"
        case .year:
            if Int(value) < labels.count && Int(value) > 0 {
                if Int(value) == labels.count - 1 {
                    return labels[Int(value)] + "     "
                }
                return labels[Int(value)]
            } else if Int(value) == 0 {
                return "     " + (labels.first ?? "")
            } else {
                return ""
            }
        }
    }
    
    
}
