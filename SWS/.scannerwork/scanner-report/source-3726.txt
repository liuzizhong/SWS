//
//  SW_SelectRangeModalView.swift
//  SWS
//
//  Created by jayway on 2018/11/19.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

typealias SelectAddressBookRangeBlock = ((SW_AddressBookModel?,SW_AddressBookModel?,SW_AddressBookModel?)->Void)

class SW_SelectRangeModalView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var tableView3: UITableView!
    
    @IBOutlet var tableViews: [UITableView]!
    
    @IBOutlet weak var selectRegionBtn: UIButton!
    
    @IBOutlet weak var selectUnitBtn: UIButton!
    
    @IBOutlet weak var selectDeptBtn: UIButton!
    
    @IBOutlet weak var selectUnitHeader: UIView!
    
    @IBOutlet weak var selectDeptHeader: UIView!
    
    private var type = AddressBookType.region
    private var sureBlock: SelectAddressBookRangeBlock?
    
    var regionDatas = [SW_AddressBookModel]()
    var unitDatas = [SW_AddressBookModel]()
    var deptDatas = [SW_AddressBookModel]()
    
    weak var modalVc: QMUIModalPresentationViewController?
    
    private var selectRegion: SW_AddressBookModel? {
        didSet {
            selectRegionBtn.setTitle(selectRegion?.name ?? "全部", for: UIControl.State())
            unitDatas = []//[SW_AddressBookModel(name: "全部", id: 0, count: selectRegion?.staffCount ?? 0)]
            tableView2.reloadData()
            selectUnit = nil
            selectDept = nil
            getUnitDatas()
        }
    }
    
    private var selectUnit: SW_AddressBookModel? {
        didSet {
            selectUnitBtn.setTitle(selectUnit?.name ?? "全部", for: UIControl.State())
            deptDatas = []//[SW_AddressBookModel(name: "全部", id: 0, count: selectUnit?.staffCount ?? 0)]
            tableView3.reloadData()
            selectDept = nil
            getDeptDatas()
        }
    }
    
    private var selectDept: SW_AddressBookModel? {
        didSet {
            selectDeptBtn.setTitle(selectDept?.name ?? "全部", for: UIControl.State())
        }
    }
    
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
        selectRegionBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        selectUnitBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        selectDeptBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        backgroundColor = .white
        layer.cornerRadius = 3
        addShadow()
        /// 获取分区数据
        getRegionDatas()
        /// 初始化view的状态
        setupViewState()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    /// 根据当前type设置views的状态
    func setupViewState() {
        switch type {
        case .region:
            tableView1.alpha = 1
            selectRegionBtn.alpha = 0
            selectUnitHeader.alpha = 0
            tableView2.alpha = 0
            selectUnitBtn.alpha = 0
            selectDeptHeader.alpha = 0
            tableView3.alpha = 0
            selectDeptBtn.alpha = 0
        case .business:
            tableView1.alpha = 0
            selectRegionBtn.alpha = 1
            selectUnitHeader.alpha = selectRegion == nil ? 0 : 1
            tableView2.alpha = selectRegion == nil ? 0 : 1
            selectUnitBtn.alpha = 0
            selectDeptHeader.alpha = 0
            tableView3.alpha = 0
            selectDeptBtn.alpha = 0
        case .department:
            tableView1.alpha = 0
            selectRegionBtn.alpha = 1
            selectUnitHeader.alpha = 1
            tableView2.alpha = 0
            selectUnitBtn.alpha = 1
            selectDeptHeader.alpha = selectUnit == nil ? 0 : 1
            tableView3.alpha = selectUnit == nil ? 0 : 1
            selectDeptBtn.alpha = 0
        default:
            tableView1.alpha = 0
            selectRegionBtn.alpha = 1
            selectUnitHeader.alpha = 1
            tableView2.alpha = 0
            selectUnitBtn.alpha = 1
            selectDeptHeader.alpha = 1
            tableView3.alpha = 0
            selectDeptBtn.alpha = 1
        }
    }
    
    
    class func show(_ sureBlock: SelectAddressBookRangeBlock?) {
        
        let modalView = Bundle.main.loadNibNamed("SW_SelectRangeModalView", owner: nil, options: nil)?.first as! SW_SelectRangeModalView
        modalView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: SCREEN_HEIGHT - NAV_HEAD_INTERVAL - TABBAR_BOTTOM_INTERVAL - 180)
        
        modalView.sureBlock = sureBlock
        
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        let vc = QMUIModalPresentationViewController()
        modalView.modalVc = vc
        vc.dimmingView = dimmingView
        vc.animationStyle = .popup
        vc.contentView = modalView
        vc.supportedOrientationMask = .portrait
        /// 动画
        vc.layoutBlock = { (containerBounds,keyboardHeight,contentViewDefaultFrame) in
            modalView.frame = CGRectSetXY(modalView.frame, CGFloatGetCenter(containerBounds.width, modalView.width), containerBounds.height - 100 - TABBAR_BOTTOM_INTERVAL - modalView.height)
        }
        
        //        modalViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        //            contentView.frame = CGRectSetY(contentView.frame, CGRectGetHeight(containerBounds));
        //            dimmingView.alpha = 0;
        //            [UIView animateWithDuration:.25 delay:0.0 options:QMUIView.AnimationOptionsCurveOut animations:^{
        //                dimmingView.alpha = 1;
        //                contentView.frame = contentViewFrame;
        //                } completion:^(BOOL finished) {
        //                // 记住一定要在适当的时机调用completion()
        //                if (completion) {
        //                completion(finished);
        //                }
        //                }];
        //        };
        //        modalViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        //            [UIView animateWithDuration:.25 delay:0.0 options:QMUIView.AnimationOptionsCurveOut animations:^{
        //                dimmingView.alpha = 0.0;
        //                contentView.frame = CGRectSetY(contentView.frame, CGRectGetHeight(containerBounds));
        //                } completion:^(BOOL finished) {
        //                // 记住一定要在适当的时机调用completion()
        //                if (completion) {
        //                completion(finished);
        //                }
        //                }];
        //        };
        
        vc.showWith(animated: true, completion: nil)
    }
    
    
    
    //MARK: -  按钮点击事件
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnClick(_ sender: UIButton) {
        sureBlock?(selectRegion,selectUnit,selectDept)
        modalVc?.hideWith(animated: true, completion: nil)
    }
    
    @IBAction func selectRegionBtnClick(_ sender: UIButton) {
        type = .region
        selectUnit = nil
        selectDept = nil
        tableView1.reloadData()
        setupViewState()
    }
    
    @IBAction func selectUnitBtnClick(_ sender: UIButton) {
        type = .business
        selectDept = nil
        tableView2.reloadData()
        setupViewState()
    }
    
    @IBAction func selectDeptBtnClick(_ sender: UIButton) {
        type = .department
        tableView3.reloadData()
        setupViewState()
    }
    
    /// 获取分区数据列表
    private func getRegionDatas() {
        SW_AddressBookService.getRegionList(SW_UserCenter.shared.user!.id).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.regionDatas = SW_AddressBookData.getDataList(json["list"].arrayValue, type: .region)
                self.regionDatas.insert(SW_AddressBookModel(name: "全部", id: 0, count: 0), at: 0)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView1.reloadData()
        })
    }
    
    /// 获取单位数据列表
    private func getUnitDatas() {
        guard let selectRegion = selectRegion else {
            return
        }
        SW_AddressBookService.getBusinessList(SW_UserCenter.shared.user!.id, regionId: selectRegion.id).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.unitDatas = SW_AddressBookData.getDataList(json["list"].arrayValue, type: .business)
                self.unitDatas.insert(SW_AddressBookModel(name: "全部", id: 0, count: 0), at: 0)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView2.reloadData()
        })
    }
    
    /// 获取部门数据列表
    private func getDeptDatas() {
        guard let selectUnit = selectUnit else {
            return
        }
        SW_AddressBookService.getDepartmentList(SW_UserCenter.shared.user!.id, bUnitId: selectUnit.id).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.deptDatas = SW_AddressBookData.getDataList(json["list"].arrayValue, type: .department)
                self.deptDatas.insert(SW_AddressBookModel(name: "全部", id: 0, count: 0), at: 0)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView3.reloadData()
        })
    }
    
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1 {
            return regionDatas.count
        } else if tableView == tableView2 {
            return unitDatas.count
        } else {
            return deptDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reUseId, for: indexPath) as! SW_SelectRangeModalViewCell
        
        if tableView == tableView1 {// 分区
            cell.model = regionDatas[indexPath.row]
            cell.isSelect = indexPath.row == 0 ? (selectRegion == nil) : (selectRegion == regionDatas[indexPath.row])
        } else if tableView == tableView2 { // a单位
            cell.model = unitDatas[indexPath.row]
            cell.isSelect = indexPath.row == 0 ? (selectUnit == nil) : (selectUnit == unitDatas[indexPath.row])
        } else { // 部门
            cell.model = deptDatas[indexPath.row]
            cell.isSelect = indexPath.row == 0 ? (selectDept == nil) : (selectDept == deptDatas[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tableView1 {
            selectRegion = indexPath.row == 0 ? nil : regionDatas[indexPath.row]
            type = .business
        } else if tableView == tableView2 {
            selectUnit = indexPath.row == 0 ? nil : unitDatas[indexPath.row]
            type = .department
        } else {
            selectDept = indexPath.row == 0 ? nil : deptDatas[indexPath.row]
            type = .contact///   contact 这个type用做选择完成后的状态
        }
        setupViewState()
    }
    
}
