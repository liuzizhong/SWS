//
//  SW_SelectArticleTypeView.swift
//  SWS
//
//  Created by jayway on 2019/1/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectArticleTypeView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    /// 最大高度
    let SW_SelectRangeViewMaxHeight: CGFloat = 261
    
    private let cellId = "ArticleTypeCellID"
    
    private var lineLayer: CAShapeLayer = {
        let line = CAShapeLayer()
        line.lineWidth = 0.5
        line.strokeColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        line.lineJoin = .round
        line.fillColor = nil
        return line
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var resetButton: QMUIButton!
    
    @IBOutlet weak var sureButton: QMUIButton!
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.alpha = 0
        return view
    }()
    
    @IBOutlet weak var stackView: UIView!
    
    private var shadowLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addShadow()
        view.alpha = 0
        return view
    }()
    
    private var sureBlock: ((NormalModel?)->Void)?
    
    private var cancelBlock: (()->Void)?
    
    private var articleTypeList = [NormalModel]()
    
    private var selectType: NormalModel?
    
    private var isShow = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetButton.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        sureButton.backgroundColor = UIColor.v2Color.blue
        stackView.addShadow(UIColor(r: 48, g: 55, b: 80, alpha: 1).withAlphaComponent(0.1))
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 0
        layout.interitemSpacing = 0
        layout.edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
        collectionView.registerNib(SW_SelectArticleTypeCell.self, forCellReuseIdentifier: cellId)
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.hide(timeInterval: FilterViewAnimationDuretion, finishBlock: { [weak self] in
                guard let self = self else { return }
                self.cancelBlock?()
            })
        }))
        /// 获取文章类型列表数据
        getArticleTypeList()
    }
    
    ///
    func show(_ selectType: NormalModel?, onView: UIView, buttonFrame: CGRect = .zero, sureBlock: @escaping (NormalModel?)->Void, cancelBlock: @escaping (()->Void)) {
        if superview != nil { return }
        isShow = true
        self.selectType = selectType
        self.sureBlock = sureBlock
        self.cancelBlock = cancelBlock
        
        let startY = buttonFrame.maxY + 10
        
        
        onView.addSubview(backgroundView)
        onView.addSubview(shadowLineView)
        backgroundView.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - startY)
        onView.addSubview(self)
        self.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDTH, height: 0)
        shadowLineView.frame = CGRect(x: 0, y: self.frame.maxY - 1, width: SCREEN_WIDTH, height: 1)
        lineLayer.path = creatPath(buttonFrame, radius: 3).cgPath
        onView.layer.addSublayer(lineLayer)
        
        self.collectionView.setContentOffset(CGPoint.zero, animated: false)
        self.collectionView.reloadData()
        let rows = ceil(CGFloat(self.articleTypeList.count)/2.0)
        let datasHeight = CGFloat(rows*54 + 44)
        let height = max(min(datasHeight, self.SW_SelectRangeViewMaxHeight), 98)
//        let height = max(min(CGFloat(self.articleTypeList.count*54 + 44), self.SW_SelectRangeViewMaxHeight), 98)
        UIView.animate(withDuration: FilterViewAnimationDuretion, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState,  animations: {
            self.backgroundView.alpha = 1
            self.height = height
        }, completion: { (finish) in
            self.shadowLineView.alpha = 1
            self.shadowLineView.frame = CGRect(x: 0, y: self.frame.maxY - 1, width: SCREEN_WIDTH, height: 1)
        })
    }
    
    func hide(timeInterval: TimeInterval, finishBlock: NormalBlock? = nil) {
        if self.superview != nil {
            isShow = false
            shadowLineView.alpha = 0
            shadowLineView.removeFromSuperview()
            if timeInterval > 0 {
                UIView.animate(withDuration: timeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.backgroundView.alpha = 0
                    self.height = 0
                }) { (finish) in
                    self.removeFromSuperview()
                    self.backgroundView.removeFromSuperview()
                    self.lineLayer.removeFromSuperlayer()
                    finishBlock?()
                }
            } else {
                lineLayer.removeFromSuperlayer()
                height = 0
                removeFromSuperview()
                backgroundView.alpha = 0
                backgroundView.removeFromSuperview()
                finishBlock?()
            }
        }
    }
    
    /// 创建线的路径
    private func creatPath(_ buttonFrame: CGRect, radius: CGFloat) -> UIBezierPath {
        let margin: CGFloat = 10
        let height: CGFloat = buttonFrame.height + margin
        /// 先的Y值
        let startY = buttonFrame.maxY + margin
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: startY))
        path.addLine(to: CGPoint(x: buttonFrame.minX - radius, y: startY))
        path.addArc(withCenter: CGPoint(x: buttonFrame.minX - radius, y: startY - radius), radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: buttonFrame.minX, y: startY - height + radius))
        path.addArc(withCenter: CGPoint(x: buttonFrame.minX + radius, y: startY - height + radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: true)
        path.addLine(to: CGPoint(x: buttonFrame.maxX - radius, y: startY - height))
        path.addArc(withCenter: CGPoint(x: buttonFrame.maxX - radius, y: startY - height + radius), radius: radius, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: buttonFrame.maxX, y: startY - radius))
        path.addArc(withCenter: CGPoint(x: buttonFrame.maxX + radius, y: startY - radius), radius: radius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi/2), clockwise: false)
        path.addLine(to: CGPoint(x: SCREEN_WIDTH, y: startY))
        return path
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    /// 根据idstr与type获取数据，可能是预加载,
    func getArticleTypeList() {
        SW_WorkingService.getArticleTypeList().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.articleTypeList = json["list"].arrayValue.map({ (value) -> NormalModel in
                    return NormalModel(value)
                })
                ///  获取请求的数据跟当前的type一致，显示view，刷新view
                if self.isShow {
                    self.collectionView.setContentOffset(CGPoint.zero, animated: false)
                    self.collectionView.reloadData()
                    let rows = ceil(CGFloat(self.articleTypeList.count)/2.0)
                    let datasHeight = CGFloat(rows*54 + 44)
                    let height = max(min(datasHeight, self.SW_SelectRangeViewMaxHeight), 98)
                    UIView.animate(withDuration: FilterViewAnimationDuretion, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState,  animations: {
                        self.backgroundView.alpha = 1
                        self.height = height
                    }, completion: { (finish) in
                        self.shadowLineView.alpha = 1
                        self.shadowLineView.frame = CGRect(x: 0, y: self.frame.maxY - 1, width: SCREEN_WIDTH, height: 1)
                    })
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        hide(timeInterval: FilterViewAnimationDuretion, finishBlock: { [weak self] in
            guard let self = self else { return }
            self.sureBlock?(self.selectType)
        })
    }
    
    @IBAction func resetBtnClick(_ sender: QMUIButton) {
        selectType = nil
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SW_SelectArticleTypeCell
        let model = articleTypeList[indexPath.item]
        cell.isSelect = model.id == selectType?.id
        cell.nameLb.text = model.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = articleTypeList[indexPath.item]
        if model.id == selectType?.id {///取消选择
            selectType = nil
        } else {
            selectType = model
        }
        collectionView.reloadData()
    }

}
extension SW_SelectArticleTypeView: FixedSpacingCollectionLayoutDelegate {
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH/2, height: 54)
        
    }
    
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
}
