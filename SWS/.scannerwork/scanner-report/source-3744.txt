//
//  File.swift
//  SWS
//
//  Created by jayway on 2018/4/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation


extension UIImage {
    /// 图片转data  太大会压缩至maxSize的大小
    ///
    /// - Parameter maxLength: 最大尺寸
    /// - Returns: 转好的data
    func compreseImage(maxSize: Int = 2000_000) -> Data? {
        var compression:CGFloat = 1.0
        guard var data = self.jpegData(compressionQuality: compression) else { return nil }
        var diminishing: CGFloat = 0.05
        if data.count > 15_000_000 {
            diminishing = 0.3
        } else if data.count > 10_000_000 {
            diminishing = 0.2
        } else if data.count > 5_000_000 {
            diminishing = 0.1
        }
        while (data.count > maxSize && compression > 0) {
            compression -= diminishing
            data = self.jpegData(compressionQuality: compression)!
        }
        return data
    }

    static var nameImages = [String:UIImage]()
    
    class func getNormalImage(_ name: String) -> UIImage {
        if let nImage = UIImage.nameImages[name] {
            return nImage
        }
        
        let rect = CGRect(x:0,y:0,width:72,height:72)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(r: 180, g: 180, b: 180).cgColor)
        context?.fill(rect)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:Font(28)]
        let textSize = NSString(string: name).size(withAttributes: textAttributes)//sizeWithAttributes(textAttributes)
        var textFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)//CGRectMake(0, 0, textSize.width, textSize.height)
        
        textFrame.origin = CGPoint(x: (rect.size.width - textSize.width)/2, y: (rect.size.height - textSize.height)/2)

        NSString(string: name).draw(in: textFrame, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImage.nameImages[name] = image
        return image!
      
    }
    
}
