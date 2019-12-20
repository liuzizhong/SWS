//
//  ScrollToTopButton.swift
//  CloudOffice
//
//  Created by 江顺金 on 2017/6/5.
//  Copyright © 2017年 115.com. All rights reserved.
//

import UIKit

//private let refreshViewHeight = CGFloat(65)

extension UIScrollView {
    
    var scrollToTopButton: ScrollToTopButton? {
        return superview?.subviews.compactMap({ subView -> ScrollToTopButton? in
            if let view = subView as? ScrollToTopButton {
                return view
            } else {
                return nil
            }
        }).first
    }
    
    func enableScrollToTop(enable: Bool) {
        superview?.subviews.compactMap({ subView -> ScrollToTopButton? in
            if let view = subView as? ScrollToTopButton {
                return view
            } else {
                return nil
            }
        }).forEach({ view in
            view.alpha = 0
        })
    }
}

@objc class ScrollToTopButton: UIView {
    
    weak var scrollView: UIScrollView?
    var scrollToTopBtn = UIButton(type: .custom)
    private var isShow = false
    
    var offset: CGFloat = 0
    
    @discardableResult
    @objc init(frame: CGRect, scrollView: UIScrollView) {
        super.init(frame: frame)
        guard let superView = scrollView.superview else {
            return
        }
        self.centerX = superView.centerX
        scrollToTopBtn.frame = superView.bounds
        scrollToTopBtn.setImage(#imageLiteral(resourceName: "icon_backtotop"), for: .normal)
        scrollToTopBtn.addTarget(self, action: #selector(scrollToTopAction), for: .touchUpInside)
        addSubview(scrollToTopBtn)
        self.scrollView = scrollView
        superView.addSubview(self)
        self.centerY = superView.height - 40
        self.isHidden = true
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        observe(scrollView, keyPath: #keyPath(UIScrollView.contentOffset)) { [weak self] (weakSelf, oldValue, newValue) in
            self?.refresh()
        }
        observe(scrollView, keyPath: #keyPath(UIScrollView.frame)) { [weak self] (weakSelf, oldValue, newValue) in
            self?.refresh()
        }
        observe(scrollView, keyPath: #keyPath(UIScrollView.contentInset)) {[weak self] (_, _, _) in
            UIView.animate(withDuration: 0.3, animations: {
                guard let s = self else {
                    return
                }
                guard let scrollView = s.scrollView else {
                    return
                }
                let inset = scrollView.contentInset.bottom
//                if scrollView.refreshFooter?.active == true {
//                    inset -= refreshViewHeight
//                }
                s.centerY = s.isShow ? scrollView.frame.maxY - inset - 40 + s.offset : scrollView.frame.maxY + 40 + s.offset
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollToTopBtn.frame = bounds
        self.centerX = (scrollView?.frame.maxX ?? SCREEN_WIDTH) - 22 - 15
    }
    
    private func refresh() {
        guard let scrollView = scrollView else {
            return
        }
        if scrollView.contentOffset.y <= 0 {
            self.hiddenScrollToTopBtn()
        } else {
            if (scrollView.isDragging || scrollView.isDecelerating) && scrollView.contentOffset.y > scrollView.height / 2 {
                self.isShow = true
                self.isHidden = false
                let inset = scrollView.contentInset.bottom
//                if scrollView.refreshFooter?.active == true {
//                    inset -= refreshViewHeight
//                }
                UIView.animate(withDuration: 0.5, animations: {
                    self.centerY = scrollView.frame.maxY - inset - 40 + self.offset
                })
            } else if self.isShow {
                self.cancelHide()
                self.perform(#selector(ScrollToTopButton.hiddenScrollToTopBtn), with: nil, afterDelay: 0.8)
            }
        }
    }
    
    /// 取消延迟执行
    private func cancelHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ScrollToTopButton.hiddenScrollToTopBtn), object: nil)
    }
    
    /// 隐藏滚到顶部按钮方法
    @objc private func hiddenScrollToTopBtn() {
        if let scrollView = scrollView, let superView = scrollView.superview {
            UIView.animate(withDuration: 0.5, animations: {
                self.centerY = superView.height + 40
            }, completion: { (true) in
                self.isHidden = true
            })
        }
    }
    
    /// 滚到顶部按钮的点击事件
    @objc private func scrollToTopAction() {
        if let tableView = scrollView as? UITableView, tableView.rowHeight == UITableView.automaticDimension && tableView.tableHeaderView == nil {
            if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                return
            }
        }
        
        if let scrollView = scrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
            // 隐藏按钮
            hiddenScrollToTopBtn()
        }
    }
    
}

