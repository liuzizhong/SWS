//
//  WebView.swift
//  CloudOffice
//
//  Created by Liu on 16/9/13.
//  Copyright © 2016年 115.com. All rights reserved.
//

import Foundation
import WebKit

class WebView: WKWebView {
    
    private(set) var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
        progressView.tintColor = UIColor.blue.withAlphaComponent(0.8)
        progressView.tintAdjustmentMode = .normal
        return progressView
    }()
    
    var hideProgressViewWhenFinished = true
    
    weak var UIContentController: UIViewController?
    weak var delegate: WKNavigationDelegate?
    
    var titleDidChange: ((String?) -> ())?
    var autoHandleError = false
    
    fileprivate weak var JSTarget: AnyObject?
    private(set) var request: URLRequest?
    fileprivate(set) weak var common: CommonJSObject?
    private var finishedLoad = false
    
    fileprivate var shouldShowError = true
    
    private lazy var errorRetryView: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(white: 0.7, alpha: 1)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        button.setImage(UIImage(named: "icon_refresh"), for: .normal)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = NSLocalizedString("网络不给力\n点击屏幕重试", comment: "")
        label.textColor = UIColor(white: 0.7, alpha: 1)
        button.addSubview(label)
        return button
    }()
    
    init(configuration: ((WKWebViewConfiguration) -> ())? = nil) {
        let webConfiguration = WebKitHelper.defaultConfiguration()
        configuration?(webConfiguration)
        super.init(frame: .zero, configuration: webConfiguration)
        self.uiDelegate = self
        self.navigationDelegate = self
    }
    
    init(frame: CGRect) {
        let webConfiguration = WebKitHelper.defaultConfiguration()
        super.init(frame: frame, configuration: webConfiguration)
        self.uiDelegate = self
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        let webConfiguration = WebKitHelper.defaultConfiguration()
        super.init(frame: .zero, configuration: webConfiguration)
        self.uiDelegate = self
        self.navigationDelegate = self
    }
    
    deinit {
        print("")
    }
    
    override func didMoveToSuperview() {
        superview?.observe(self, keyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, mainThread: true) { [weak self] (object, oldValue, value) in
            if let value = value as? Double {
                self?.estimatedProgressDidChange(oldValue as? Double, progress: value)
            }
        }
        superview?.observe(self, keyPath: #keyPath(WKWebView.title)) { [weak self] (object, oldValue, value) in
            self?.titleDidChange?(self?.title)
        }
    }
    
    @discardableResult func loadUrlString(_ urlString: String) -> WKNavigation? {
        if let request = SW_HttpHelper.verificationURL(urlString) {
            return self.load(request)
        }
        return nil
    }
    
   @discardableResult override func load(_ request: URLRequest) -> WKNavigation? {
        guard let url = request.url else {
            return nil
        }
        let mRequest = NSMutableURLRequest(url: url, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
        mRequest.appendCookies()
        self.request = mRequest as URLRequest
        self.finishedLoad = false
        return super.load(mRequest as URLRequest)
    }
    
    private func estimatedProgressDidChange(_ oldValue: Double?, progress: Double) {
        if finishedLoad {
            if oldValue != 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.progressView.progress = 1
                    }, completion: { (completion) in
                        UIView.animate(withDuration: 0.3, animations: { 
                            self.progressView.alpha = 0
                        })
                })
            }
        } else {
            let animated = progress > (oldValue ?? Double(progressView.progress))
            progressView.setProgress(Float(progress), animated: animated)
            let p = progress == 1
            let a = progressView.alpha == 1
            if p == a {
                if !p {
                    self.progressView.alpha = 1
                } else {
                    UIView.animate(withDuration: 0.3, delay: (progress - (oldValue ?? 0)) * 0.9, options: .beginFromCurrentState, animations: {
                        self.progressView.alpha = 0
                        }, completion: { (completion) in
                            
                    })
                }
            }
        }
    }
    
    func loadFailed(with error: Error) {
        guard shouldShowError else {
            return
        }
        if errorRetryView.superview == nil {
            self.addSubview(errorRetryView)
            errorRetryView.addTarget(self, action: #selector(self.retry), for: .touchUpInside)
            errorRetryView.center = CGPoint(x: self.width / 2, y: self.height / 2)
        }
        errorRetryView.isHidden = false
    }
    
    @objc func retry() {
        errorRetryView.isHidden = true
        if let request = self.request {
            _ = self.load(request)
        } else {
            _ = self.reload
        }
    }
    
}

extension WebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let delegate = delegate, delegate.responds(to: #selector(WebView.webView(_:decidePolicyFor:decisionHandler:))) {
            delegate.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        shouldShowError = false
        delegate?.webView?(webView, didFinish: navigation)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if autoHandleError && error.code != NSURLErrorCancelled {
            loadFailed(with: error)
        }
        delegate?.webView?(webView, didFail: navigation, withError: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if autoHandleError && error.code != NSURLErrorCancelled {
            loadFailed(with: error)
        }
        delegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
            return
        }
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
    
}

extension WebView: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {//新建webview
//        if let ctrl = delegate as? UIViewController, let url = navigationAction.request.url {
//            ctrl.openURLString(url.absoluteString)
//        }
        return nil
    }

    func webViewDidClose(_ webView: WKWebView) {
        
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (action) in
            completionHandler()
        }))
        let controlloer = UIContentController ?? UIApplication.shared.keyWindow?.rootViewController
        controlloer?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .default, handler: { (action) in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (action) in
            completionHandler(true)
        }))
        let controlloer = UIContentController ?? UIApplication.shared.keyWindow?.rootViewController
        controlloer?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController.init(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { [weak alertController] (action) in
            completionHandler(alertController?.textFields?.first?.text);
        }))
        alertController.addTextField { textField in
            textField.text = defaultText
        }
        let controlloer = UIContentController ?? UIApplication.shared.keyWindow?.rootViewController
        controlloer?.present(alertController, animated: true, completion: nil)
    }
}

extension WebView {
    
    func registerJSExport(_ object: AnyObject) {
        self.JSTarget = object
        
        if let object = object as? JSPrototol {
            let commonObj = CommonJSObject(target: object)
//            commonObj.webView = self
            self.loadPlugin(commonObj, namespace: "SWSJS.common")
            self.common = commonObj
        }
       
        if object is JSPrototol {
            var js = ["SWSJS.common.getUserInfo = function(){ return SWSJS.common.userInfo; }"]
            js.append("SWSJS.common.fontScale = function(){ return SWSJS.common.fontScaleValue; }")
            js.append("SWSJS.common.appVersion = function(){ return SWSJS.common.applicationVersion; }")
            js.append("SWSJS.common.netWorkState = function(){ return SWSJS.common.netWorkStatus; }")
//            js.append("SWSJS.common.stringInPasteboard = function(){ return SWSJS.common.stringInPasteboard; }")
//            js.append("SWSJS.common.getApplyPostUserInfo = function(){ return SWSJS.common.applyPostUserInfo; }")
            let script = WKUserScript(source: js.joined(separator: ";"), injectionTime: .atDocumentStart, forMainFrameOnly: true)
            self.configuration.userContentController.addUserScript(script)
        }
    }
    
}

