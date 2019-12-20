//
//  UIColorExtension.swift
//  SWS
//
//  Created by jayway on 2018/4/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation


// MARK: UIColor的工具类
extension UIColor {
    
    
    /// 第二设计版本颜色
    struct v2Color {
        /// 主体蓝色-#1377FA UIColor(r: 19, g: 119, b: 250)
        static let blue  = #colorLiteral(red: 0.07450980392, green: 0.4666666667, blue: 0.9803921569, alpha: 1)
        /// 主体红色-#f25555 UIColor(r: 242, g: 85, b: 85)
        static let red  = #colorLiteral(red: 0.9490196078, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        /// 主体深黑色-#151515 UIColor(r: 21, g: 21, b: 21)
        static let darkBlack  = #colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1)
        /// 主体浅黑色-#333333 UIColor(r: 51, g: 51, b: 51)
        static let lightBlack  = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        /// 灰色-#666666 UIColor(r: 102, g: 102, b: 102)
        static let darkGray  = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        /// 浅灰色-#999999 UIColor(r: 153, g: 153, b: 153)
        static let lightGray  = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        /// 按钮不可用颜色-#CCCCCC UIColor(r: 204, g: 204, b: 204)
        static let disable  = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        /// 分割线颜色-#E5E5E5 UIColor(r: 229, g: 229, b: 229)
        static let separator  = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        /// 空数据文字颜色
        static let emptyTextColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
    
    
    struct mainColor {
        static let blue  = #colorLiteral(red: 0.07450980392, green: 0.4666666667, blue: 0.9803921569, alpha: 1) //UIColor(r: 69, g: 153, b: 224, alpha: 1)//主体蓝色
        static let darkBlack  = #colorLiteral(red: 0.07450980392, green: 0.07450980392, blue: 0.07450980392, alpha: 1)//UIColor(r: 19, g: 19, b: 19, alpha: 1)//黑色字体颜色
        static let gray  = #colorLiteral(red: 0.4431372549, green: 0.4431372549, blue: 0.4431372549, alpha: 1)//UIColor(r: 113, g: 113, b: 113, alpha: 1)
        static let lightGray  = #colorLiteral(red: 0.6392156863, green: 0.6392156863, blue: 0.6392156863, alpha: 1)//UIColor(r: 163, g: 163, b: 163, alpha: 1)
        static let disable  = #colorLiteral(red: 0.5764705882, green: 0.768627451, blue: 0.9333333333, alpha: 1)//UIColor(r: 147, g: 169, b: 238, alpha: 1)//按钮不可用颜色
        static let separator  = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)//UIColor(r: 235, g: 235, b: 235, alpha: 1)//分割线颜色
        static let background  = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)//UIColor(hex: "#f5f5f5")//背景灰色
        static let tabBarNormal = #colorLiteral(red: 0.462745098, green: 0.4784313725, blue: 0.4862745098, alpha: 1)//UIColor(r: 118, g: 122, b: 124, alpha: 1)//底部未选中颜色
    }
    
    static let StatisticalChartColors = [#colorLiteral(red: 0.2705882353, green: 0.6, blue: 0.8784313725, alpha: 1),#colorLiteral(red: 0.07058823529, green: 0.5490196078, blue: 0.5294117647, alpha: 1),#colorLiteral(red: 0, green: 0.7725490196, blue: 0.6901960784, alpha: 1),#colorLiteral(red: 1, green: 0.568627451, blue: 0.1882352941, alpha: 1),#colorLiteral(red: 0.1490196078, green: 0.7764705882, blue: 0.8549019608, alpha: 1),#colorLiteral(red: 0.3019607843, green: 0.7960784314, blue: 0.4509803922, alpha: 1),#colorLiteral(red: 0.9490196078, green: 0.3882352941, blue: 0.4823529412, alpha: 1),#colorLiteral(red: 0.7411764706, green: 0.06274509804, blue: 0.8784313725, alpha: 1),#colorLiteral(red: 0.9607843137, green: 0.2274509804, blue: 0.2, alpha: 1),#colorLiteral(red: 0.5803921569, green: 0.831372549, blue: 0.831372549, alpha: 1),#colorLiteral(red: 0.9725490196, green: 0.9058823529, blue: 0.1098039216, alpha: 1),#colorLiteral(red: 0.7490196078, green: 0.5254901961, blue: 0.5254901961, alpha: 1),#colorLiteral(red: 1, green: 0.7568627451, blue: 0.2, alpha: 1),#colorLiteral(red: 0.1725490196, green: 0.8431372549, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1),#colorLiteral(red: 0.4470588235, green: 0, blue: 0.7960784314, alpha: 1),#colorLiteral(red: 1, green: 0.4156862745, blue: 0.4156862745, alpha: 1),#colorLiteral(red: 0.7647058824, green: 0.1137254902, blue: 0.1137254902, alpha: 1),#colorLiteral(red: 0.2, green: 0.1921568627, blue: 0.8392156863, alpha: 1),#colorLiteral(red: 0.2352941176, green: 0.4352941176, blue: 0.9607843137, alpha: 1)]
    
    static func getStatisticalChartColor(_ index: Int) -> UIColor {
        if index >= StatisticalChartColors.count {
            return UIColor.randomColor()
        } else {
            return StatisticalChartColors[index]
        }
        
    }
    
    /// UIColor的初始化方法
    ///
    /// - Parameters:
    ///   - r: 红(0-255)
    ///   - g: 绿(0-255)
    ///   - b: 蓝(0-255)
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    
    /// UIColor的初始化方法
    ///
    /// - Parameters:
    ///   - r: 红(0-255)
    ///   - g: 绿(0-255)
    ///   - b: 蓝(0-255)
    ///   - alpha: 透明度(0-1)
    convenience init(r: Int, g: Int, b: Int, alpha: Float = 1) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
    }
    
    /// UIColor的灰色初始化方法
    ///
    /// - Parameters:
    ///   - white: 灰色(0-255)
    convenience init(white: Int) {
        self.init(red: CGFloat(white) / 255.0, green: CGFloat(white) / 255.0, blue: CGFloat(white) / 255.0, alpha: 1)
    }
    
    /// 随机一个颜色
    ///
    /// - Returns: 返回一个随机色
    class func randomColor() -> UIColor {
        return UIColor(r: Int(arc4random() % 256), g: Int(arc4random() % 256), b: Int(arc4random() % 256))
    }
    
    /// UIColor的初始化方法，十六进制的串转成颜色
    ///
    /// - Parameters:
    ///   - hex: 十六进制的串
    ///   - alpha: 透明度(0-1)
    convenience init?(hex:String, alpha: Float = 1) {
        var colorStr = hex.trimmingCharacters(in: NSCharacterSet.whitespaces).uppercased()
        if (colorStr.length < 6) {
            return nil
        }
        if (colorStr.hasPrefix("0X")) {
            colorStr = (colorStr as NSString).substring(from: 2)
        }
        if (colorStr.hasPrefix("#")) {
            colorStr = (colorStr as NSString).substring(from: 1)
        }
        if (colorStr.length != 6) {
            return nil
        }
        // Separate into r, g, b substrings
        var range = NSRange.init(location: 0, length: 2)
        //r
        let rString = (colorStr as NSString).substring(with: range)
        //g
        range.location = 2;
        let gString = (colorStr as NSString).substring(with: range)
        //b
        range.location = 4;
        let bString = (colorStr as NSString).substring(with: range)
        // Scan values
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        _ = (Scanner.localizedScanner(with: rString) as AnyObject).scanHexInt32(&r)
        _ = (Scanner.localizedScanner(with: gString) as AnyObject).scanHexInt32(&g)
        _ = (Scanner.localizedScanner(with: bString) as AnyObject).scanHexInt32(&b)
        self.init(r: Int(r), g: Int(g), b: Int(b), alpha: alpha)
    }
    
}
