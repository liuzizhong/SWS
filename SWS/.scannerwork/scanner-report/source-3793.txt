//
//  SW_HttpHelper.swift
//  SWS
//
//  Created by jayway on 2018/5/14.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_HttpHelper: NSObject {

    static let RegularLink = "(^\\s*http[s]?:\\/\\/([\\w-]+\\.)+[\\w-]+([\\w-.\\/;()@+,#-$_!:?%&=]*)?)|(^\\s*([a-zA-Z0-9_-]+\\.)+(com|cn|net|org|asia|cc|biz|tv|me|pw|wang|im|hk|info|mobi|name|gov|fm)(\\/[a-zA-Z0-9_/.\\-?%&amp;=:]*)?)"
    
    class func verificationURL(_ URLString: String) -> URLRequest? {
        //#是用来做url喵点所用，不能转，转了之后无法正常打开url
        //如果链接中有多个#，则只能保留第一个#，其他的需要转掉
        var tempURL = URLString.removingPercentEncoding ?? URLString
        let customAllowedSet =  CharacterSet(charactersIn:"`%^{}\"[]|\\<> ").inverted
        //var tempURL = URLString
        if let range = tempURL.range(of: "#") {
            let str1 = String(tempURL[..<range.upperBound])
            //            let str1 = tempURL.substring(to: range.upperBound)
            let str2 = String(tempURL[range.upperBound...])
            //            let str2 = tempURL.substring(from: range.upperBound)
            let customAllowedSetTemp =  CharacterSet(charactersIn:"#`%^{}\"[]|\\<> \n").inverted
            if let str1Encode = str1.addingPercentEncoding(withAllowedCharacters:               customAllowedSet) {
                tempURL = str1Encode
            }
            if let str2Encode = str2.addingPercentEncoding(withAllowedCharacters: customAllowedSetTemp) {
                tempURL += str2Encode
            }
        }else{
            if let strEncode = tempURL.addingPercentEncoding(withAllowedCharacters: customAllowedSet){
                tempURL = strEncode
            }
        }
        var dealURLString = tempURL
        let strRange = NSMakeRange(0, dealURLString.count)
        let regex = try? NSRegularExpression(pattern: RegularLink, options: .caseInsensitive)
        if let matches = regex?.matches(in: dealURLString, options: [], range:strRange) {
            if !(matches.count > 0) {
                return nil
            }
        }
        dealURLString = self.addHttpProtocol(dealURLString)
        
        //if let urlString = self.filterNoAccessURLs(dealURLString).stringByRemovingPercentEncoding {
        //    if let urlString1 = urlString.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        //    {
        if let URL = URL(string: dealURLString as String)
        {
            let request = URLRequest(url: URL)
            return request
        }
        //    }
        //}
        
        return nil
        //}
    }
    
    class func addHttpProtocol(_ dealURLString: String) -> String {
        var URLString = dealURLString
        if !URLString.hasPrefix("http://") && !dealURLString.hasPrefix("https://") {
            URLString = "http://" + dealURLString
        }
        return URLString
    }
    
}
