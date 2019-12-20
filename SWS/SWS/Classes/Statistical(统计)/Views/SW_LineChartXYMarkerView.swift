//
//  SW_LineChartXYMarkerView.swift
//  SWS
//
//  Created by jayway on 2018/8/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import Charts

class SW_LineChartXYMarkerView: BalloonMarker {
//    public var xAxisValueFormatter: IAxisValueFormatter
    
    fileprivate var yFormatter = NumberFormatter()
    
    public override init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
//        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumIntegerDigits = 1
        yFormatter.minimumFractionDigits = 0
        yFormatter.maximumFractionDigits = 2
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
//        let index = Int(xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())) ?? 1
        let string =  yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
        setLabel(string)
    }
}
