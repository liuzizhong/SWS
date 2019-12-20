//
//  SW_SelectRangeView.swift
//  SWS
//
//  Created by jayway on 2018/12/4.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectRangeView: UIView, UITableViewDelegate, UITableViewDataSource {
    /// 最大高度
    let SW_SelectRangeViewMaxHeight = SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 223
    
    // 当前列表显示的数据范围
    private var type = RangeType.region
    
    private let rangeCellId = "rangeCellID"
    
    private var lineLayer: CAShapeLayer = {
        let line = CAShapeLayer()
        line.lineWidth = 0.5
        line.strokeColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        line.lineJoin = .round
        line.fillColor = nil
        return line
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sureButton: QMUIButton!
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.alpha = 0
        return view
    }()
    
    private var sureBlock: ((SW_RangeManager)->Void)?
    
    private var cancelBlock: (()->Void)?
    
    private var currentList: [SW_RangeModel] {
        get {
            switch type {
            case .region:
                return regionList
            case .business:
                return bunitList
            case .department:
                return deptList
            default:
                return []
            }
        }
    }
    /// 预加载分区列表数据
    private var regionList = [SW_RangeModel]()
    /// 预加载单位列表数据
    private var bunitList = [SW_RangeModel]()
    /// 预加载部门列表数据
    private var deptList = [SW_RangeModel]()
    /// 当前页面选择的范围管理，与real不一样
    private var rangeManager: SW_RangeManager!
    
    /// 用于预加载的manager，这个改变就要重新获取数据
    var realRangeManager: SW_RangeManager! {
        didSet {
            deptList = []
            if realRangeManager.selectBuses.count > 0 {/// 预加载部门
                getListAndReload(realRangeManager.getSelectRangesIdStr(type: .business), dataType: .department)
            }
            bunitList = []
            if realRangeManager.selectRegs.count > 0 {/// 预加载单位
                getListAndReload(realRangeManager.getSelectRangesIdStr(type: .region), dataType: .business)
            }
        }
    }
    
    private var isShow = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        sureButton.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        sureButton.backgroundColor = UIColor.v2Color.blue
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.hide(timeInterval: FilterViewAnimationDuretion, finishBlock: { [weak self] in
                guard let self = self else { return }
                self.cancelBlock?()
            })
            
        }))
        /// 先获取分区数据
        getListAndReload("", dataType: .region)
    }
    
    ///
    func show(_ rangeManager: SW_RangeManager, pageType: RangeType, onView: UIView, buttonFrame: CGRect = .zero, sureBlock: @escaping (SW_RangeManager)->Void, cancelBlock: @escaping (()->Void)) {
        if superview != nil { return }
        isShow = true
        self.type = pageType
        self.rangeManager = rangeManager.copy() as? SW_RangeManager
        self.sureBlock = sureBlock
        self.cancelBlock = cancelBlock
        
        let startY = buttonFrame.maxY + 10
        onView.addSubview(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - startY)
        onView.addSubview(self)
        self.frame = CGRect(x: 0, y: startY, width: SCREEN_WIDTH, height: 0)
        lineLayer.path = creatPath(buttonFrame, radius: 3).cgPath
        onView.layer.addSublayer(lineLayer)
        
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        self.tableView.reloadData()
        let height = max(min(CGFloat(self.currentList.count*54 + 44), self.SW_SelectRangeViewMaxHeight), 98)
        UIView.animate(withDuration: FilterViewAnimationDuretion, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState,  animations: {
            self.backgroundView.alpha = 1
            self.height = height
        }, completion: nil)
        
        if currentList.count == 0 {
            var idStr = ""
            switch type {
            case .business:
                idStr = rangeManager.getSelectRangesIdStr(type: .region)
            case .department:
                idStr = rangeManager.getSelectRangesIdStr(type: .business)
            default:
                break
            }
            getListAndReload(idStr, dataType: type)
        }
        
    }
    
    func hide(timeInterval: TimeInterval, finishBlock: NormalBlock? = nil) {
        if self.superview != nil {
            isShow = false
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
                self.height = 0
                self.removeFromSuperview()
                backgroundView.alpha = 0
                self.backgroundView.removeFromSuperview()
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
    
    func setList(_ dateType: RangeType, datas: [SW_RangeModel]) {
        switch dateType {
        case .region:
            regionList = datas
        case .business:
            bunitList = datas
        case .department:
            deptList = datas
        default:
            break
        }
    }
    
    /// 根据idstr与type获取数据，可能是预加载,
    func getListAndReload(_ idStr: String, dataType: RangeType) {
        SW_RangeService.getAddGroupMemberList(dataType.rawValue, GroupNum: nil, staffId: SW_UserCenter.shared.user!.id, idStr: idStr).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                var datas = json["list"].arrayValue.map({ (value) -> SW_RangeModel in
                    return SW_RangeModel(value, type: dataType)
                })
                if datas.count > 1 {
                    datas.insert(SW_RangeModel(), at: 0)
                }
                self.setList(dataType, datas: datas)
                ///  获取请求的数据跟当前的type一致，显示view，刷新view
                if self.isShow , dataType == self.type {
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    self.tableView.reloadData()
                    let height = max(min(CGFloat(self.currentList.count*54 + 44), self.SW_SelectRangeViewMaxHeight), 98)
                    UIView.animate(withDuration: FilterViewAnimationDuretion, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState,  animations: {
                        self.backgroundView.alpha = 1
                        self.height = height
                    }, completion: nil)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    func selectAllBtnClick(isSelect: Bool) {
        //进行全选 不选后、
        if isSelect {
            rangeManager.setSelectRangesAll(type: type, models:  getCurrentList())
        } else {
            rangeManager.removeSelectRanges(type: type)
        }
        tableView.reloadData()
    }
    
    func isSelectAll() -> Bool {
        return rangeManager.isSelectRangesAll(type: type, models: getCurrentList())
    }
    
    func getCurrentList() -> [SW_RangeModel] {
        var lists = currentList
        if lists.first?.id == 0 {
            lists.remove(at: 0)
        }
        return lists
    }
    
    /// d范围改变，全选cell更新
    func rangeChangeAction() {
        if currentList.count > 0 {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        hide(timeInterval: FilterViewAnimationDuretion, finishBlock: { [weak self] in
            guard let self = self else { return }
            self.sureBlock?(self.rangeManager)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        let model = currentList[indexPath.row]
        if model.id == 0 {// 全部按钮x项
            cell.rangeModel = model
            cell.centerLb.text = "全部"
            cell.isSelect = isSelectAll()
        } else {
            cell.rangeModel = model
            cell.isSelect = rangeManager.isSelectRange(model: currentList[indexPath.row])
        }
        cell.centerCountLb.isHidden = true
        cell.topCountLb.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if model.id == 0 {
            /// 全选非全选
            selectAllBtnClick(isSelect: !isSelectAll())
        } else {
            if rangeManager.isSelectRange(model: model) {
                rangeManager.removeSelectRange(model: model)
            } else {
                rangeManager.setSelectRange(model: model)
            }
            rangeChangeAction()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
}
