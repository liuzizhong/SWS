//
//  SW_SelectWarehouseNoView.swift
//  SWS
//
//  Created by jayway on 2019/3/26.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

/// 选中仓位号成功
typealias SelectWarehouseNoBlock = ((String,String,String,String)->Void)

class SW_SelectWarehouseNoView: UIView, UITableViewDelegate, UITableViewDataSource {
    /// 选中的仓库id
    private var warehouseId = ""
    
    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var tableView3: UITableView!
    
    @IBOutlet weak var tableView4: UITableView!
    
    @IBOutlet var tableViews: [UITableView]!
    
    private var sureBlock: SelectWarehouseNoBlock?
    
    var allDatas = [SW_WarehousePositionArea]() {
        didSet {
            /// 初始化，回选数据
            if let index = allDatas.firstIndex(where: { return $0.areaNum == startArea }) {
                selectArea = allDatas[index]
            }
            if let index = selectArea?.shelfNums.firstIndex(where: { return $0.shelfNum == startShelf }) {
                selectShelf = selectArea?.shelfNums[index]
            }
            if let index = selectShelf?.layerNums.firstIndex(where: { return $0.layerNum == startLayer }) {
                selectLayer = selectShelf?.layerNums[index]
            }
            selectseatNum = startSeatNum
        }
    }
    /// 初始数据
    private var startArea = ""
    private var startShelf = ""
    private var startLayer = ""
    private var startSeatNum = ""
    
//    weak var modalVc: QMUIModalPresentationViewController?
    
    private var selectArea: SW_WarehousePositionArea? {
        didSet {
            selectShelf = nil
            selectLayer = nil
            selectseatNum = nil
            tableView2.reloadData()
        }
    }
    
    private var selectShelf: SW_WarehousePositionShelf? {
        didSet {
            selectLayer = nil
            selectseatNum = nil
            tableView3.reloadData()
        }
    }
    
    private var selectLayer: SW_WarehousePositionLayer? {
        didSet {
            selectseatNum = nil
            tableView4.reloadData()
        }
    }
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.dismissView()
        }))
        return view
    }()
    
    private var selectseatNum: String?
    
    private let reUseId = "SW_SelectRangeModalViewCellID"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableViews.forEach({
            $0.registerNib(SW_SelectRangeModalViewCell.self, forCellReuseIdentifier: reUseId)
            $0.tableFooterView = UIView()
            if #available(iOS 11.0, *) {
                $0.contentInsetAdjustmentBehavior = .never
            }
        })
        backgroundColor = .white
//        layer.cornerRadius = 3
        addShadow()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    class func show(_ warehouseId: String, area: String, shelf: String, layer: String, seat: String, sureBlock: SelectWarehouseNoBlock?) {
        let modalView = Bundle.main.loadNibNamed("SW_SelectWarehouseNoView", owner: nil, options: nil)?.first as! SW_SelectWarehouseNoView
        modalView.warehouseId = warehouseId
        modalView.startArea = area
        modalView.startShelf = shelf
        modalView.startLayer = layer
        modalView.startSeatNum = seat
        modalView.getAllDatas()
        modalView.sureBlock = sureBlock
        
        MYWINDOW?.addSubview(modalView.dimmingView)
        modalView.dimmingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        MYWINDOW?.addSubview(modalView)
        modalView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        MYWINDOW?.layoutIfNeeded()
        modalView.snp.updateConstraints { (update) in
            update.height.equalTo(SCREEN_HEIGHT*0.85)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            MYWINDOW?.layoutIfNeeded()
            modalView.dimmingView.alpha = 1
        }, completion: nil)
        
    }
    
    //MARK: -  按钮点击事件

    private func doneAction() {
        sureBlock?(selectArea!.areaNum,selectShelf!.shelfNum,selectLayer!.layerNum,selectseatNum!)
        dismissView()

    }
    
    private func dismissView() {
        self.snp.updateConstraints { (update) in
            update.height.equalTo(0)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (finish) in
            self.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
        }
    }
    
    /// 获取分区数据列表
    private func getAllDatas() {
        SW_WorkingService.getWarehousePositionList(warehouseId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.allDatas = json.arrayValue.map({ return SW_WarehousePositionArea($0) })
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView1.reloadData()
        })
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return allDatas.count
        } else if tableView == tableView2 {
            return selectArea?.shelfNums.count ?? 0
        } else if tableView == tableView3 {
            return selectShelf?.layerNums.count ?? 0
        } else {
            return selectLayer?.seatNums.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseId, for: indexPath) as! SW_SelectRangeModalViewCell
        cell.nameLabel.textAlignment = .center
        if tableView == tableView1 {
            cell.nameLabel.text = allDatas[indexPath.row].areaNum
            cell.isSelect = selectArea?.areaNum == allDatas[indexPath.row].areaNum
        } else if tableView == tableView2 {
            cell.nameLabel.text = selectArea?.shelfNums[indexPath.row].shelfNum
            cell.isSelect = selectShelf?.shelfNum == selectArea?.shelfNums[indexPath.row].shelfNum
        } else if tableView == tableView3 {
            cell.nameLabel.text = selectShelf?.layerNums[indexPath.row].layerNum
            cell.isSelect = selectLayer?.layerNum == selectShelf?.layerNums[indexPath.row].layerNum
        } else {
            cell.nameLabel.text = selectLayer?.seatNums[indexPath.row]
            cell.isSelect = selectseatNum == selectLayer?.seatNums[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tableView1 {
            selectArea = allDatas[indexPath.row]
        } else if tableView == tableView2 {
            selectShelf = selectArea?.shelfNums[indexPath.row]
        } else if tableView == tableView3  {
            selectLayer = selectShelf?.layerNums[indexPath.row]
        } else {
            selectseatNum = selectLayer?.seatNums[indexPath.row]
            doneAction()
            return
        }
        tableView.reloadData()
    }
}

class SW_WarehousePositionArea: NSObject {
    
    var areaNum = ""
    
    var shelfNums = [SW_WarehousePositionShelf]()
    
    init(_ areaNum: String) {
        super.init()
        self.areaNum = areaNum
    }
    
    init(_ json: JSON) {
        super.init()
        areaNum = json["areaNum"].stringValue
        shelfNums = json["shelfNums"].arrayValue.map({ return SW_WarehousePositionShelf($0) })
    }
}

class SW_WarehousePositionShelf: NSObject {
    
    var shelfNum = ""
    
    var layerNums = [SW_WarehousePositionLayer]()
    
    init(_ shelfNum: String) {
        super.init()
        self.shelfNum = shelfNum
    }
    
    init(_ json: JSON) {
        super.init()
        shelfNum = json["shelfNum"].stringValue
        layerNums = json["layerNums"].arrayValue.map({ return SW_WarehousePositionLayer($0) })
    }
}

class SW_WarehousePositionLayer: NSObject {
    
    var layerNum = ""
    
    var seatNums = [String]()
    
    init(_ layerNum: String) {
        super.init()
        self.layerNum = layerNum
    }
    
    init(_ json: JSON) {
        super.init()
        layerNum = json["layerNum"].stringValue
        seatNums = json["seatNums"].arrayValue.map({ return $0.stringValue })
    }
}

