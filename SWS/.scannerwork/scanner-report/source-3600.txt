//
//  SW_RingCarKeyFrameModel.swift
//  SWS
//
//  Created by jayway on 2019/5/18.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

/// 记录环车检视关键帧数据模型
struct SW_RingCarKeyFrameModel {
    
    var time: CGFloat = 0
    
    var keyProblem = ""
    
    var image: UIImage? = nil
    
    init(time: CGFloat, keyProblem: String, image: UIImage? = nil) {
        self.time = time
        self.keyProblem = keyProblem
        self.image = image
    }
}
