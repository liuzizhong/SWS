//
//  WebKitHelper.swift
//  CloudOffice
//
//  Created by Liu on 16/9/12.
//  Copyright © 2016年 115.com. All rights reserved.
//

import Foundation
import WebKit

class WebKitHelper {
    
    class func defaultConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = .all
        } else {
            // Fallback on earlier versions
        }
        
        let userContentController = WKUserContentController()
        
        if let script = HTTPCookieStorage.shared.cookies?.map({ "document.cookie='\($0.cookieString)'" }).joined(separator: ";") {
            let cookieInScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(cookieInScript)
        }
        
        configuration.userContentController = userContentController
        return configuration
    }
    
}

extension NSMutableURLRequest {
    
    func appendCookies() {
        guard let URL = url else {
            return
        }
        let cookies = HTTPCookieStorage.shared.cookies?.filter {
            var cookieDomain = $0.domain
            if cookieDomain.hasPrefix(".") {
                cookieDomain = cookieDomain.substring(from: cookieDomain.index(cookieDomain.startIndex, offsetBy: 1))
            }
            return URL.host?.hasSuffix(cookieDomain) ?? false
        }
        if let cookies = cookies {
            let header = cookies.map{ "\($0.name)=\($0.value)" }.joined(separator: ";")
            self.setValue(header, forHTTPHeaderField: "Cookie")
        }
    }
    
}

extension HTTPCookie {
    
    var cookieString: String {
        return "\(name)=\(value);domain=\(domain);expiresDate=\(expiresDate ?? Date());path=\(path);sessionOnly=\(self.isSecure ? "TRUE" : "FALSE");isSecure=\(self.isSessionOnly ? "TRUE" : "FALSE")"
    }
    
}
