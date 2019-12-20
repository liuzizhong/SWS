//
//  SW_CommonWebViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/11.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import WebKit

class SW_CommonWebViewController: UIViewController {
//    fileprivate var webIsLoaded = false
//    fileprivate var loadRequestCallback: (([String: Any])->Void)?
//    fileprivate var loadRequestErrorCallback: (()->Void)?
    fileprivate var urlString = "" {
        didSet {
//            self.webView.reload()
            self.webView.loadUrlString(urlString)
        }
    }
    let webView = WebView { (configuration) in
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = []
        }
    }
    
    var isShowTitle = true
    
    init(urlString: String) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.webView.registerJSExport(self)
        self.webView.delegate = self
        self.webView.frame = self.view.bounds
        
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.webView)
        self.webView.titleDidChange = { [weak self] (title) in
            if self?.isShowTitle == true {            
                self?.navigationItem.title = title
            }
        }
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView.progressView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 2)
        self.webView.progressView.progressTintColor = UIColor.v2Color.blue
        self.view.addSubview(self.webView.progressView)
        self.webView.progressView.autoresizingMask = .flexibleWidth
        
        self.webView.loadUrlString(urlString)
    }
    
    deinit {
        PrintLog("deintit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func show_user_info(_ userID: Any) {
        PrintLog(userID)
    }
    
    func getUserInfo() -> [String: String] {
        return ["token": SW_UserCenter.shared.user?.token ?? ""]
    }
    
    func showUserInfoWithGid(_ userID: String, _ gid: String) {
        PrintLog(userID)
    }
}


// MARK: - WKNavigationDelegate
extension SW_CommonWebViewController: WKNavigationDelegate {
    func showError(_ error: Error) {
        if error.code == -1009 {
//            MBProgressHUD.show(kMBProgressHUDImageFail, text: NSLocalizedString("网络异常，请重试", comment: ""))
        } else if error.code == -1003 {
//            MBProgressHUD.show(kMBProgressHUDImageFail, text: NSLocalizedString("无法打开此链接", comment: ""))
        } else {
            if error.code != -999 {
//                MBProgressHUD.showError(error)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
   
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.webIsLoaded = true
//        var jsStr = ""
//        do {
//            if let url = Bundle.main.url(forResource: "taskDetail", withExtension: "js") {
//                try jsStr = String(contentsOf: url, encoding: String.Encoding.utf8)
//                jsStr = jsStr.replacingOccurrences(of: "$_JS_Template_NetworkState_$", with: "\(NetWorkState.shareNetWork().netWorkStatus.rawValue)")
//            }
//            webView.evaluateJavaScript(jsStr, completionHandler: nil)
//        } catch {}
//        webView.evaluateJavaScript(jsStr, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
//        if url.scheme == "oof.office" {
//            let selector = Selector(url.host! + ":")
//            if self.responds(to: selector) {
//                let index  = ("oof.office://" + url.host! + "/").count
//                var params = [String: Any]()
//                if url.absoluteString.count > index {
//                    var paramsStr = url.absoluteString.substring(from: url.absoluteString.index(url.absoluteString.startIndex, offsetBy: index))
//                    paramsStr =? (paramsStr as NSString).removingPercentEncoding
//                    if let dic = paramsStr.jsonValue() as? [String: Any] {
//                        params = dic
//                    }
//                }
//                if self.responds(to: selector) {
//                    self.perform(selector, with: params)
//                }
//                decisionHandler(.cancel)
//            }
//        }
        
        if navigationAction.navigationType == .linkActivated {
            if (navigationAction.request.url?.absoluteString) != nil {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
