//
//  NotificationExtensions.swift
//  Browser
//
//  Created by 粽子 on 11/12/17.
//  Copyright © 2017年 114la.com. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    
    //自定义通知扩展
    struct Ex {
        //MARK: - 全局红点通知
        /// 红点通知接口获取到数据后发出通知更新UI
        static let RedDotNotice = NSNotification.Name(rawValue: "ex_RedDotNotice")
        
        //MARK: - 用户操作
        /// 登录手机号 第一手机号改变
        static let UserPhoneNum1HadChange = NSNotification.Name(rawValue: "ex_UserPhoneNum1HadChange")
        /// 头像改变
        static let UserPortraitHadChange = NSNotification.Name(rawValue: "ex_UserPortraitHadChange")
        
        //MARK: - 群组操作
        /// 创建群组
        static let UserGroupListDidUpdate = NSNotification.Name(rawValue: "ex_UserGroupListDidUpdate")
        /// 添加、删除群成员成功
        static let GroupMembersHadChange = NSNotification.Name(rawValue: "ex_GroupMembersHadChange")
        /// 群说明修改成功
        static let GroupDescriptionHadChange = NSNotification.Name(rawValue: "ex_GroupDescriptionHadChange")
        /// 群主修改成功
        static let GroupOwnerHadChange = NSNotification.Name(rawValue: "ex_GroupOwnerHadChange")
        /// 修改群名称
        static let UserHadChangeGroupName = NSNotification.Name(rawValue: "ex_UserHadChangeGroupName")
        /// 修改群头像
        static let UserHadChangeGroupIcon = NSNotification.Name(rawValue: "ex_UserHadChangeGroupIcon")
        /// 工作群状态被修改，启用或者禁用
        static let GroupStateHadChange = NSNotification.Name(rawValue: "ex_GroupStateHadChange")
        //MARK: - 营收报表模块通知
        /// 用户新建营收报表
        static let UserHadCreatRevenueReport = NSNotification.Name(rawValue: "ex_UserHadCreatRevenueReport")
        /// 用户编辑营收报表
        static let UserHadEditRevenueReport = NSNotification.Name(rawValue: "ex_UserHadEditRevenueReport")
        //MARK:- 公告操作
        /// 用户发出了公告
        static let UserHadPostInform = NSNotification.Name(rawValue: "ex_UserHadPostInform")
        /// 用户收藏或者取消收藏公告
        static let UserHadChangeCollectionInform = NSNotification.Name(rawValue: "ex_UserHadChangeCollectionInform")
        
        //MARK:- 共享资料模块通知
        /// 用户收藏或者取消收藏共享资料文章
        static let UserHadChangeCollectionArticle = NSNotification.Name(rawValue: "ex_UserHadChangeCollectionArticle")
        /// 文章的阅读数已更新
        static let ArticleReadCountHadUpdate = NSNotification.Name(rawValue: "ex_ArticleReadCountHadUpdate")
        
        //MARK: - 聊天相关通知
        /// 聊天未读数改变
        static let HuanXinHadLogin = NSNotification.Name(rawValue: "ex_HuanXinHadLogin")
        /// 聊天记录被清空
        static let ChatMessagesHadClear = NSNotification.Name(rawValue: "ex_ChatMessagesHadClear")
        /// 聊天未读数改变
        static let SetupUnreadMessageCount = NSNotification.Name(rawValue: "ex_SetupUnreadMessageCount")
        /// 聊天会话置顶状态改变
        static let TopConversationsHadChange = NSNotification.Name(rawValue: "ex_TopConversationsHadChange")
        
        //MARK: - token校验相关通知
        /// token校验并更新用户数据
        static let UserHadCheckAndUpdate = NSNotification.Name(rawValue: "ex_UserHadCheckAndUpdate")
        
        //MARK: - 审核相关通知
        /// 审核状态发生改变
        static let ReviewStateHadChange = NSNotification.Name(rawValue: "ex_ReviewStateHadChange")
        /// 已经获取到App Store的版本信息
        static let HadGetAppStoreVersion = NSNotification.Name(rawValue: "ex_HadGetAppStoreVersion")
        
        //MARK: - 工作报告相关通知
        /// 成功选择接收人
        static let HadSelectPushMember = NSNotification.Name(rawValue: "ex_HadSelectPushMember")
        /// 用户新建工作报告
        static let UserHadCreatWorkReport = NSNotification.Name(rawValue: "ex_UserHadCreatWorkReport")
        /// 用户编辑工作报告
        static let UserHadEditWorkReport = NSNotification.Name(rawValue: "ex_UserHadEditWorkReport")
        /// 用户查看了自己的工作报告 - 消除红点
        static let UserHadLookMineWorkReport = NSNotification.Name(rawValue: "ex_UserHadLookMineWorkReport")
        /// 用户审阅了工作报告 - 消除红点
        static let UserHadCommentWorkReport = NSNotification.Name(rawValue: "ex_UserHadCommentWorkReport")
        /// 用户无权限查看该报告，接收人被修改了
        static let UserCantLookWorkReport = NSNotification.Name(rawValue: "ex_UserCantLookWorkReport")
        /// 用户工作报告刚刚被审阅了
        static let WorkReportByReviewed = NSNotification.Name(rawValue: "ex_WorkReportByReviewed")
        
        //MARK: - 客户关系相关通知
        /// 用户编辑了客户意向通知
        static let UserHadEditCustomerIntention = NSNotification.Name(rawValue: "ex_UserHadEditCustomerIntention")
        /// 用户开始了销售接待
        static let UserHadStartSalesReception = NSNotification.Name(rawValue: "ex_UserHadStartSalesReception")
        /// 用户结束了销售接待
        static let UserHadEndSalesReception = NSNotification.Name(rawValue: "ex_UserHadEndSalesReception")
        /// 销售接待被后台结束了
        static let SalesReceptionHadBeenEnd = NSNotification.Name(rawValue: "ex_SalesReceptionHadBeenEnd")
        /// 用户添加了访问记录
        static let UserHadAddAccessRecord = NSNotification.Name(rawValue: "ex_UserHadAddAccessRecord")
        /// 用户开始了试乘试驾
        static let UserHadStartTryDriving = NSNotification.Name(rawValue: "ex_UserHadStartTryDriving")
        /// 用户结束了试乘试驾
        static let UserHadEndTryDriving = NSNotification.Name(rawValue: "ex_UserHadEndTryDriving")
        /// 客户已经被转移
        static let CustomerHadBeenChange = NSNotification.Name(rawValue: "ex_CustomerHadBeenChange")
        /// 用户修改了客户头像
        static let UserHadSaveCustomerPortrait = NSNotification.Name(rawValue: "ex_UserHadSaveCustomerPortrait")
        /// 用户新增客户
        static let UserHadCreateCustomer = NSNotification.Name(rawValue: "ex_UserHadCreateCustomer")
        
        /// 用户关注了某个客户
        static let UserHadFollowCustomer = NSNotification.Name(rawValue: "ex_UserHadFollowCustomer")
        
        /// 质检列表更新
        static let OrderListHadBeenChange = NSNotification.Name(rawValue: "ex_OrderListHadBeenChange")
        
        /// 重新开始扫描
        static let BarCodeScanShouldReStart = NSNotification.Name(rawValue: "ex_BarCodeScanShouldReStart")
        
        /// 销售合同业务办理
        static let SalesContractBusinessDandling = NSNotification.Name(rawValue: "ex_SalesContractBusinessDandling")
        /// 销售合同被审核
        static let SalesContractHadAudit = NSNotification.Name(rawValue: "ex_SalesContractHadAudit")
        /// 待办事务需要更新数量
        static let BackLogCountUpdate = NSNotification.Name(rawValue: "ex_BackLogCountUpdate")
        
        /// 用户处理了客户投诉
        static let UserHadHandleComplaints = NSNotification.Name(rawValue: "ex_UserHadHandleComplaints")
    }
    
}


