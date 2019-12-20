//
//  SW_InformCollectView.swift
//  SWS
//
//  Created by jayway on 2018/5/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InformCollectView: UIView {

    @IBOutlet weak var readCountLb: UILabel!
    
    @IBOutlet weak var collectionBtn: UIButton!
    
    var informId = 0 {
        didSet {
            self.requestInformInfo()
        }
    }
    
    var readRecordBlock: NormalBlock?
    
    private var isRequesting = false
    
    private func requestInformInfo() {
        SW_WorkingService.getIsCollectAndReadMsg(SW_UserCenter.shared.user!.id, msgId: informId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.collectionBtn.isEnabled = true
                self.readCountLb.text = "阅读 \(json["readedCount"].intValue)/\(json["acceptCount"].intValue)"
                // isCollect  1  已收藏    0未收藏
                self.collectionBtn.isSelected = json["isCollect"].intValue == 1
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    @IBAction func readRecordBtnClick(_ sender: UIButton) {
        
        readRecordBlock?()
    }
    
    @IBAction func collectionBtnClick(_ sender: UIButton) {
        guard !isRequesting else { return }
        isRequesting = true
        let isSelected = sender.isSelected
        (isSelected ? SW_WorkingService.disCollectMsg(informId) : SW_WorkingService.collectMsg(informId)).response({ (json, isCache, error) in
            if error == nil {
                sender.isSelected = !isSelected
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadChangeCollectionInform, object: nil)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.isRequesting = false
        })
    }
    
}
