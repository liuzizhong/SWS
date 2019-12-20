//
//  SW_ProtocolViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import WebKit

class SW_ProtocolViewController: UIViewController {

    let webView = WebView { (configuration) in
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = InternationStr("效率+用户协议")
        
        view.backgroundColor = UIColor.white
        webView.registerJSExport(self)
        webView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)

        webView.progressView.frame = CGRect(x: 0, y: 0, width: view.width, height: 2)
        webView.progressView.progressTintColor = UIColor.mainColor.blue
        view.addSubview(webView.progressView)
        webView.progressView.autoresizingMask = .flexibleWidth
        webView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.top.equalToSuperview()
        }
        
        if let filePath = Bundle.main.path(forResource: "protocol", ofType: "html"), let html = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8) {
            webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: filePath))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
}
// MARK: - WKNavigationDelegate
extension SW_ProtocolViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
