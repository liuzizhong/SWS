//
//  SW_RefreshHeader.swift
//  SWS
//
//  Created by jayway on 2019/2/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RefreshHeader: MJRefreshGifHeader {
    
    override func prepare() {
        super.prepare()
        
        lastUpdatedTimeLabel.isHidden = true
//        isAutomaticallyChangeAlpha = true
        stateLabel.isHidden = false
        stateLabel.font = Font(10)
        stateLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        setTitle("下拉刷新", for: .idle)
        setTitle("松开刷新", for: .pulling)
        setTitle("刷新中", for: .refreshing)
        
        let refreshingImgs = UIImage.praseGIF(toImageArray: "refreshing.gif")
        // resize image
        let refreshingLittleImgs = refreshingImgs?.map({ (image) -> Any in
            if let image = image as? UIImage {
                return UIImage.init(image: image, scaledTo: CGSize(width: 35, height: 35))
            }
            return image
        })
        setImages(refreshingLittleImgs, duration: 1, for: .refreshing)
        let idleImgs = UIImage.praseGIF(toImageArray: "idleing.gif")
        // resize image little
        var idleLittleImgs = idleImgs?.map({ (image) -> Any in
            if let image = image as? UIImage {
                return UIImage.init(image: image, scaledTo: CGSize(width: 35, height: 35))
            }
            return image
        })
        if let firstImage = idleLittleImgs?.first {
            for _ in 0...60 {//经过计算得出，改变总高度会改变，这是60的时候
                idleLittleImgs?.insert(firstImage, at: 0)
            }
        }
        setImages(idleLittleImgs, for: .idle)
        
        mj_h = 70
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        gifView.contentMode = .center
//        gifView.frame = CGRect(x: 0, y: 5, width: self.mj_w, height: 35)
        gifView.frame = CGRect(x: (SCREEN_WIDTH-35)/2, y: 5, width: 35, height: 35)
        stateLabel.frame = CGRect(x: (SCREEN_WIDTH-60)/2-2, y: 45, width: 60, height: 15)
    }
    
//    #pragma mark - Overwritten by subclass
//
//    - (void)prepare NS_REQUIRES_SUPER;
//    - (void)placeSubviews NS_REQUIRES_SUPER;
//    - (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
//    - (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
//    - (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
//
//
}
