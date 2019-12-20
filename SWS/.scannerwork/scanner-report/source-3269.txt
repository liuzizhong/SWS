//
//  SW_InformWebViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import WebKit

class SW_InformWebViewController: UIViewController, JSPrototol, UIScrollViewDelegate {
    
    private var urlString = ""
    
    private var informId = 0
    
    let webView = WebView { (configuration) in
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = []
        }
    }
    
    let bottomView: SW_InformCollectView = {
        let view = Bundle.main.loadNibNamed("SW_InformCollectView", owner: nil, options: nil)?.first as! SW_InformCollectView
        return view
    }()
    
    init(urlString: String, informId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.informId = informId
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
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
//        self.webView.scrollView.delegate = self
//        self.webView.titleDidChange = { [weak self] (title) in
            self.navigationItem.title = "公告详情"
//        }
        
        self.webView.progressView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 2)
        self.webView.progressView.progressTintColor = UIColor.mainColor.blue
        self.view.addSubview(self.webView.progressView)
        self.webView.progressView.autoresizingMask = .flexibleWidth
        
        self.bottomView.readRecordBlock = { [weak self] in
            PrintLog("addshfbajhsdfksjafd")
            self?.navigationController?.pushViewController(SW_InformReadRecordViewController(self?.informId ?? 0), animated: true)
        }
        self.bottomView.informId = self.informId

        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM_INTERVAL + 44)
            make.bottom.equalToSuperview()//.offset(TABBAR_BOTTOM_INTERVAL + 44)
        }
        self.webView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        
//        observe(webView, keyPath: #keyPath(WebView.scrollView.contentSize)) { [weak self] (observer, old, new) in
//            if let old = old as? CGSize, old.height == (new as! CGSize).height {
//                return
//            }
//            guard let self = self else { return }
//            if self.webView.isLoading || (new as! CGSize).height == 0 {
//                return
//            }
//            self.showOrHideBottomView(isShow: (new as! CGSize).height <= self.webView.scrollView.height+100)
//        }
        
        self.webView.loadUrlString(urlString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    private func showOrHideBottomView(isShow: Bool, animated: Bool = true) {
//        bottomView.snp.updateConstraints { (update) in
//            update.bottom.equalToSuperview().offset(isShow ? 0 : TABBAR_BOTTOM_INTERVAL + 44)
//        }
//        UIView.animate(withDuration: animated ? FilterViewAnimationDuretion : 0, delay: 0, options: .allowUserInteraction,  animations: {
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//    }
    
    deinit {
//        self.webView.scrollView.delegate = nil
//        removeObserve(webView)
        PrintLog("deinit")
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if self.webView.isLoading {
//            return
//        }
//        showOrHideBottomView(isShow: scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height - 150)
//    }
    
}


// MARK: - WKNavigationDelegate
extension SW_InformWebViewController: WKNavigationDelegate {
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
//        showOrHideBottomView(isShow: self.webView.scrollView.contentSize.height <= self.webView.scrollView.height+100)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
