//
//  JSProtocol.swift
//  CloudOffice
//
//  Created by strangeliu on 15/10/19.
//  Copyright © 2015年 115.com. All rights reserved.
//

import Foundation

@objc protocol JSPrototol: NSObjectProtocol {
    
    @objc optional func updateReadCount(_ readCount: Int)
    
    @objc optional func showTitle(_ isShow: Any)
    
    @objc optional func show_user_info(_ userID: Any)
    
    @objc optional func getUserInfo() -> [String: String]
    
    @objc optional func showUserInfoWithGid(_ userID: String, _ gid: String)
    
}

