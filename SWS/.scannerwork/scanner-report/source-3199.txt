//
//  SW_SelectSearchDateViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/4.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

/// 最大加载消息数量
let maxLoadMessagesCount: Int32 = 59999

class SW_SelectSearchDateViewController: QMUICommonViewController, PDTSimpleCalendarViewDelegate {
    
    private var conversation: EMConversation!
    
    /// 用于存放有消息的时间数组 .simpleTimeString(formatter: .year) 格式刷
    private var hadMsgDateStrs = [String]()
    
    var chatTitle = ""
    var regionStr = ""
    
    init(_ conversation: EMConversation) {
        super.init(nibName: nil, bundle: nil)
        self.conversation = conversation
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.titleView?.horizontalTitleFont = Font(16)
        self.titleView?.tintColor = UIColor.v2Color.lightBlack
        self.titleView?.verticalTitleFont = Font(16)
        title = "按日期查找"
        
        showEmptyViewWithLoading()
        
        conversation.loadMessagesStart(fromId: nil, count: maxLoadMessagesCount, searchDirection: EMMessageSearchDirectionUp) { [weak self] (messages, error) in
            guard let self = self else { return }
            /// 加载出9999条消息出来
            guard let messages = messages as? [EMMessage] else {
                return
            }
            DispatchQueue.global().async {
                /// 处理有i消息的日期，存在一个数组中
                var msgDates = [String]()
                for msg in messages {
                    let msgDateStr = Date.dateWith(timeInterval: TimeInterval(msg.localTime)).simpleTimeString(formatter: .year)
                    if !msgDates.contains(msgDateStr) {
                        msgDates.append(msgDateStr)
                    }
                }
                self.hadMsgDateStrs = msgDates

                dispatch_async_main_safe {
                    var firstDate: Date
                    if messages.count > 0 {
                        firstDate = Date.dateWith(timeInterval: TimeInterval(messages.first!.localTime))
                    } else {
                        firstDate = Date()
                    }
                    let calenderVc = PDTSimpleCalendarViewController()
                    calenderVc.weekdayTextType = .veryShort
                    calenderVc.weekdayHeaderEnabled = true
                    calenderVc.delegate = self
                    calenderVc.firstDate = firstDate
                    calenderVc.overlayTextColor = UIColor.v2Color.lightBlack
                    calenderVc.lastDate = Date()
                    self.hideEmptyView()
                    self.addChild(calenderVc)
                    calenderVc.view.frame = CGRect(x: 0, y: NAV_TOTAL_HEIGHT, width: self.view.width, height: self.view.height - NAV_TOTAL_HEIGHT)
                    self.view.addSubview(calenderVc.view)
                    calenderVc.didMove(toParent: self)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func simpleCalendarViewController(_ controller: PDTSimpleCalendarViewController!, didSelect date: Date!) {
        guard let vc = SW_ChatViewController(conversation: conversation, timeInterval: Int64(date.getCurrentTimeInterval())) else { return }
        vc.title = chatTitle
        vc.regionStr = regionStr
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func simpleCalendarViewController(_ controller: PDTSimpleCalendarViewController!, isEnabledDate date: Date!) -> Bool {
        return hadMsgDateStrs.contains(date.simpleTimeString(formatter: .year))
    }
    
    func simpleCalendarViewController(_ controller: PDTSimpleCalendarViewController!, shouldUseCustomColorsFor date: Date!) -> Bool {
        return true
    }

    func simpleCalendarViewController(_ controller: PDTSimpleCalendarViewController!, textColorFor date: Date!) -> UIColor! {
        return UIColor.v2Color.lightBlack
    }

    func simpleCalendarViewController(_ controller: PDTSimpleCalendarViewController!, circleColorFor date: Date!) -> UIColor! {
        return UIColor.clear
    }

}
