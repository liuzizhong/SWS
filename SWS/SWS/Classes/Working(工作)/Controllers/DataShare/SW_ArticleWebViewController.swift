//
//  SW_ArticleWebViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import WebKit

class SW_ArticleWebViewController: UIViewController, JSPrototol, UIScrollViewDelegate {
    
    private var article: SW_DataShareListModel!
    
    private let webView = WebView { (configuration) in
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = []
        }
    }
    
    private let bottomView: SW_ArticleCollectionBarView = {
        let view = Bundle.main.loadNibNamed("SW_ArticleCollectionBarView", owner: nil, options: nil)?.first as! SW_ArticleCollectionBarView
        return view
    }()
    
    private var navTitleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
//        view.alpha = 0
        return view
    }()
    
    init(_ article: SW_DataShareListModel) {
        super.init(nibName: nil, bundle: nil)
        self.article = article
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
        self.view.addSubview(self.webView)
//        self.webView.scrollView.delegate = self
//        self.webView.titleDidChange = { [weak self] (title) in
//            self?.navigationItem.title = title
//        }
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        self.webView.progressView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 2)
        self.webView.progressView.progressTintColor = UIColor.mainColor.blue
        self.view.addSubview(self.webView.progressView)
        self.webView.progressView.autoresizingMask = .flexibleWidth
        
        self.bottomView.article = self.article
        
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
        
        let nameLb = UILabel()
        nameLb.text = article.publisher
        nameLb.textColor = UIColor.v2Color.lightBlack
        nameLb.font = Font(16)
        navTitleView.addSubview(nameLb)
        nameLb.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
            make.width.lessThanOrEqualTo(200)
        }
        let imageView = UIImageView()
        if !article.publisherPortrait.isEmpty, let url = URL(string: article.publisherPortrait.thumbnailString()) {
            imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icon_personalavatar"))
        } else {
            imageView.image = #imageLiteral(resourceName: "icon_personalavatar")
        }
        navTitleView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(nameLb.snp.leading).offset(-10)
            make.width.height.equalTo(25)
        }
        imageView.layer.cornerRadius = 12.5
        imageView.layer.masksToBounds = true
        navTitleView.isHidden = true
        navigationItem.titleView = navTitleView
        
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
        
        self.webView.loadUrlString(article.showUrl + "&value=\(SW_UserCenter.shared.user!.id)"/* + "&t=\(Date().getCurrentTimeInterval())"*/)
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
//        webView.scrollView.delegate = nil
//        removeObserve(webView)
        PrintLog("deinit")
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if self.webView.isLoading {
//            return
//        }
//        showOrHideBottomView(isShow: scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height - 150)
//    }
    
    func updateReadCount(_ readCount: Int) {
//        showAlertMessage("updateReadCount\(readCount)", MYWINDOW)
        bottomView.readCountLb.text = "阅读  \(readCount)"
        NotificationCenter.default.post(name: NSNotification.Name.Ex.ArticleReadCountHadUpdate, object: nil, userInfo: ["articleId": article.id, "readedCount": readCount])
    }
    
    func showTitle(_ isShow: Any) {
//        showAlertMessage("收到前端js showTitle(_ isShow: Any)：\(isShow)", MYWINDOW)
        let isShow = isShow as? Bool ?? false
//        navTitleView.alpha = isShow ? 1 : 0
        navTitleView.isHidden = !isShow
    }
}


// MARK: - WKNavigationDelegate
extension SW_ArticleWebViewController: WKNavigationDelegate {
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
