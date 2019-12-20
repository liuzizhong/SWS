//
//  SW_ArticleCollectionBarView.swift
//  SWS
//
//  Created by jayway on 2019/1/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ArticleCollectionBarView: UIView {
    
    @IBOutlet weak var readCountLb: UILabel!
    
    @IBOutlet weak var collectionBtn: UIButton!
    
    private var isRequesting = false
    
    var article: SW_DataShareListModel? {
        didSet {
            guard let article = article else { return }
            readCountLb.text = "阅读  \(article.readedCount)"
            collectionBtn.isSelected = article.isCollect
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    @IBAction func collectionBtnClick(_ sender: UIButton) {
        guard let article = article else { return }
        guard !isRequesting else { return }
        isRequesting = true
        let isSelected = sender.isSelected

        (isSelected ? SW_WorkingService.disCollectArticle(article.id) : SW_WorkingService.collectArticle(article.id)).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                sender.isSelected = !isSelected
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadChangeCollectionArticle, object: nil, userInfo: ["article": article, "isCollect": !isSelected])
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            self.isRequesting = false
        })
    }
    
}
