//
//  SW_AddBoutiquesAccessoriesViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AddBoutiquesAccessoriesViewController: FormViewController {
    
    private var boutiquesAccessories: SW_BoutiquesAccessoriesModel!
    private var purchaseOrderId = ""
    private var type: ProcurementType = .boutiques
    /// 扫描获得的code
    private var code = ""
    private var isRequesting = false

    //MARK: - 内存中存一些接口数据，第一次时请求，后则使用内存数据
    /// 仓库列表
    private var warehouseList = [NormalModel]()
    /// 维修种类列表
    private var accessoriesTypeList = [NormalModel]()
    /// 精品种类列表
    private var boutiqueTypeList = [NormalModel]()
    
    init(_ code: String, type: ProcurementType, purchaseOrderId: String, supplier: String, supplierId: String) {
        super.init(nibName: nil, bundle: nil)
        self.code = code
        self.boutiquesAccessories = SW_BoutiquesAccessoriesModel(code: code, type: type)
        self.boutiquesAccessories.supplier = supplier
        self.boutiquesAccessories.supplierId = supplierId
        self.purchaseOrderId = purchaseOrderId
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Action
    private func formConfig() {

        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        rowKeyboardSpacing = 89
        navigationItem.title = NSLocalizedString("新增\(type.rawTitle)参数", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(commitAction(_:)))
        
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
        }
    }
    
    private func createTableView() {
        
        form = Form()
            +++
            Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "必填信息"
                }
                section.header = header
            }
        
            <<< SW_CommenFieldRow("name") {
                $0.rawTitle = NSLocalizedString("\(type.rawTitle)名称", comment: "")
                $0.value = boutiquesAccessories.name
                $0.cell.valueField.keyboardType = .default
                $0.cell.valueField.placeholder = "请输入\(type.rawTitle)名称"
                $0.cell.valueField.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.name = $0.value ?? ""
        }
        
            <<< SW_CommenLabelRow("code") {
                $0.rawTitle = NSLocalizedString("\(type.rawTitle)条码", comment: "")
                $0.value = boutiquesAccessories.code
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                })
        
            <<< SW_CommenFieldRow("num") {
                $0.rawTitle = NSLocalizedString("\(type.rawTitle)编号", comment: "")
                $0.value = boutiquesAccessories.num
                $0.cell.valueField.keyboardType = .asciiCapable
                $0.cell.valueField.placeholder = "请输入\(type.rawTitle)编号"
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.num = $0.value ?? ""
        }
        
            <<< SW_CommenLabelRow("supplier") {
                $0.rawTitle = NSLocalizedString("供应商名称", comment: "")
                $0.value = boutiquesAccessories.supplier
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                })
            
        if type == .accessories {
            form.last!
            <<< SW_CommenLabelRow("accessoriesTypeName") {
                $0.rawTitle = NSLocalizedString("配件种类", comment: "")
                $0.value = boutiquesAccessories.accessoriesTypeName
                $0.cell.placeholder = "点击选择配件种类"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    if self!.accessoriesTypeList.count > 0 {
                        self?.showAccessoriesTypePicker()
                    } else {
                        guard !self!.isRequesting else { return }
                        self?.isRequesting = true
                        SW_WorkingService.getAccessoriesTypeList().response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.accessoriesTypeList = json["list"].arrayValue.map({ return NormalModel($0["accessoriesTypeName"].stringValue, id: $0["accessoriesTypeId"].stringValue) })
                                self?.showAccessoriesTypePicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                            self?.isRequesting = false
                        })
                    }
                })
        } else {
            form.last!
                <<< SW_CommenLabelRow("boutiqueTypeName") {
                    $0.rawTitle = NSLocalizedString("精品种类", comment: "")
                    $0.value = boutiquesAccessories.boutiqueTypeName
                    $0.cell.placeholder = "点击选择精品种类"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        if self!.boutiqueTypeList.count > 0 {
                            self?.showBoutiqueTypePicker()
                        } else {
                            guard !self!.isRequesting else { return }
                            self?.isRequesting = true
                            SW_WorkingService.getBoutiqueTypeList().response({ (json, isCache, error) in
                                if let json = json as? JSON, error == nil {
                                    self?.boutiqueTypeList = json["list"].arrayValue.map({ return NormalModel($0["boutiqueTypeName"].stringValue, id: $0["boutiqueTypeId"].stringValue) })
                                    self?.showBoutiqueTypePicker()
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                                self?.isRequesting = false
                            })
                        }
                    })
        }
        
        //// 适用车型  ---
        //TODO: --- 适用车型
        form.last!
            <<< SW_ApplicableCarModelRow("forCarModelType") {
                $0.value = boutiquesAccessories.forCarModelType
                $0.carModel = boutiquesAccessories.carBrand.isEmpty ? "" : "\(boutiquesAccessories.carBrand)  \(boutiquesAccessories.carSeries)"
                let theRow = $0
                $0.carClickBlock = { [weak self, weak theRow] in
                    guard let self = self else { return }
                    self.navigationController?.pushViewController(SW_SelectCarModelViewController(.unit, successBlock: { (brand, series, model) in
                        self.boutiquesAccessories.carSeries = series.name
                        self.boutiquesAccessories.carSeriesId = series.id
                        self.boutiquesAccessories.carBrand = brand.name
                        self.boutiquesAccessories.carBrandId = brand.id
                        
                        theRow?.carModel = self.boutiquesAccessories.carBrand.isEmpty ? "" : "\(self.boutiquesAccessories.carBrand)  \(self.boutiquesAccessories.carSeries)"
                        theRow?.updateCell()
                    }, isFinishBySeries: true), animated: true)
                    
                }
                
                }.onChange({ [weak self] (row) in
                    guard let self = self else { return }
                     self.boutiquesAccessories.forCarModelType = row.value ?? 1
                    row.carModel = self.boutiquesAccessories.carBrand.isEmpty ? "" : "\(self.boutiquesAccessories.carBrand)  \(self.boutiquesAccessories.carSeries)"
                    row.reload()
                })
                
                
            <<< SW_CommenLabelRow("warehouseName") {
                $0.rawTitle = NSLocalizedString("所在仓库", comment: "")
                $0.value = boutiquesAccessories.warehouseName
                $0.cell.placeholder = "点击选择所在仓库"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    if self!.warehouseList.count > 0 {
                        self?.showWarehousePicker()
                    } else {
                        guard !self!.isRequesting else { return }
                        self?.isRequesting = true
                        SW_WorkingService.getWarehouseList(self?.type ?? .boutiques).response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.warehouseList = json["list"].arrayValue.map({ return NormalModel($0["name"].stringValue, id: $0["id"].stringValue) })
                                self?.showWarehousePicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                            self?.isRequesting = false
                        })
                    }
                })
        
            <<< SW_CommenLabelRow("Position no") {
                $0.rawTitle = NSLocalizedString("仓位号(选填)", comment: "")
                if boutiquesAccessories.warehousePositionNum.isEmpty {
                    $0.value = ""
                } else {
                    $0.value = boutiquesAccessories.warehousePositionNum
                }
                $0.cell.placeholder = "点击选择仓位号"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    guard let self = self else { return }
                    if self.boutiquesAccessories.warehouseId.isEmpty {
                        showAlertMessage("请选择所在仓库", MYWINDOW)
                        return
                    }
                    SW_SelectWarehouseNoView.show(self.boutiquesAccessories.warehouseId, area: self.boutiquesAccessories.areaNum, shelf: self.boutiquesAccessories.shelfNum, layer: self.boutiquesAccessories.layerNum, seat: self.boutiquesAccessories.seatNum, sureBlock: { (area, shelf, layer, seat) in
                        self.boutiquesAccessories.areaNum = area
                        self.boutiquesAccessories.shelfNum = shelf
                        self.boutiquesAccessories.layerNum = layer
                        self.boutiquesAccessories.seatNum = seat
                        row.value = self.boutiquesAccessories.warehousePositionNum//"\(area)-\(shelf)-\(layer)-\(seat)"
                        row.updateCell()
                    })
                })
        
            <<< SW_CommenLabelRow("unit") {
                $0.rawTitle = NSLocalizedString("单位", comment: "")
                $0.value = boutiquesAccessories.unit
                $0.cell.placeholder = "点击选择单位"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    BRStringPickerView.showStringPicker(withTitle: "单位", on: MYWINDOW, dataSource: ["套","只","件","个","台","瓶","米"], defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
                        PrintLog(selectValue)
                        self?.boutiquesAccessories.unit = selectValue as? String ?? ""
                        row.value = self?.boutiquesAccessories.unit
                        row.updateCell()
                    })
                })
        
        
            <<< SW_CommenFieldRow("specification") {
                $0.rawTitle = NSLocalizedString("规格(选填)", comment: "")
                $0.value = boutiquesAccessories.specification
                $0.cell.valueField.keyboardType = .default
                $0.cell.valueField.placeholder = "请输入规格"
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.specification = $0.value ?? ""
        }
        
            <<< SW_CommenFieldRow("retailPrice") {
                $0.rawTitle = NSLocalizedString("零售价", comment: "")
                $0.decimalCount = 4
                $0.isAmount = true
                $0.value = boutiquesAccessories.retailPrice == 0 ? "" :  "\(boutiquesAccessories.retailPrice)"
                $0.cell.valueField.keyboardType = .decimalPad
                $0.cell.valueField.placeholder = "请输入零售价"
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.retailPrice = Double($0.value ?? "") ?? 0
        }
        
            <<< SW_CommenFieldRow("costPriceTax") {
                $0.rawTitle = NSLocalizedString("含税成本价", comment: "")
                $0.decimalCount = 4
                $0.isAmount = true
                $0.value = boutiquesAccessories.costPriceTax == 0 ? "" : "\(boutiquesAccessories.costPriceTax)"
                $0.cell.valueField.keyboardType = .decimalPad
                $0.cell.valueField.placeholder = "请输入含税成本价"
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.costPriceTax = Double($0.value ?? "") ?? 0
        }
        
            <<< SW_CommenFieldRow("claimPrice") {
                $0.rawTitle = NSLocalizedString("索赔价", comment: "")
                $0.decimalCount = 4
                $0.isAmount = true
                $0.value = boutiquesAccessories.claimPrice == 0 ? "" : "\(boutiquesAccessories.claimPrice)"
                $0.cell.valueField.keyboardType = .decimalPad
                $0.cell.valueField.placeholder = "请输入索赔价"
                }.onChange { [weak self] in
                    self?.boutiquesAccessories.claimPrice = Double($0.value ?? "") ?? 0
        }
        
        if type == .boutiques {
            form.last!
                <<< SW_CommenFieldRow("hourlyWage") {
                    $0.rawTitle = NSLocalizedString("工时费", comment: "")
                    $0.decimalCount = 4
                    $0.isAmount = true
                    $0.value = boutiquesAccessories.hourlyWage == 0 ? "" : "\(boutiquesAccessories.hourlyWage)"
                    $0.cell.valueField.keyboardType = .decimalPad
                    $0.cell.valueField.placeholder = "请输入工时费"
                    }.onChange { [weak self] in
                        self?.boutiquesAccessories.hourlyWage = Double($0.value ?? "") ?? 0
            }
        }

        tableView.reloadAndFadeAnimation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - private 方法  显示pickerview
    /// 显示仓库列表pickerview
    private func showWarehousePicker() {
        guard warehouseList.count > 0 else { return }
        guard let row = form.rowBy(tag: "warehouseName") as? SW_CommenLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "所在仓库", on: MYWINDOW, dataSource: warehouseList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            PrintLog(selectValue)
            if let index = self.warehouseList.index(where: { return $0.name == selectValue  as? String ?? ""}) {
                self.boutiquesAccessories.warehouseName = self.warehouseList[index].name
                self.boutiquesAccessories.warehouseId = self.warehouseList[index].id
                row.value = self.boutiquesAccessories.warehouseName
                row.updateCell()
                if let positionRow = self.form.rowBy(tag: "Position no") as? SW_CommenLabelRow {
                    positionRow.value = self.boutiquesAccessories.warehousePositionNum.isEmpty ? "" : self.boutiquesAccessories.warehousePositionNum
                    positionRow.updateCell()
                }
            }
        })
    }
    
    /// 显示配件种类pickerview
    private func showAccessoriesTypePicker() {
        guard accessoriesTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "accessoriesTypeName") as? SW_CommenLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "配件种类", on: MYWINDOW, dataSource: accessoriesTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            PrintLog(selectValue)
            if let index = self.accessoriesTypeList.index(where: { return $0.name == selectValue  as? String ?? ""}) {
                self.boutiquesAccessories.accessoriesTypeName = self.accessoriesTypeList[index].name
                self.boutiquesAccessories.accessoriesTypeId = self.accessoriesTypeList[index].id
                row.value = self.boutiquesAccessories.accessoriesTypeName
                row.updateCell()
            }
        })
    }
    
    /// 显示精品种类pickerview
    private func showBoutiqueTypePicker() {
        guard boutiqueTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "boutiqueTypeName") as? SW_CommenLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "精品种类", on: MYWINDOW, dataSource: boutiqueTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            PrintLog(selectValue)
            if let index = self.boutiqueTypeList.index(where: { return $0.name == selectValue  as? String ?? ""}) {
                self.boutiquesAccessories.boutiqueTypeName = self.boutiqueTypeList[index].name
                self.boutiquesAccessories.boutiqueTypeId = self.boutiqueTypeList[index].id
                row.value = self.boutiquesAccessories.boutiqueTypeName
                row.updateCell()
            }
        })
    }
    
    private func showErrorLine() {
        (form.rowBy(tag: "name") as? SW_CommenFieldRow)?.showErrorLine()
        (form.rowBy(tag: "num") as? SW_CommenFieldRow)?.showErrorLine()
        (form.rowBy(tag: "retailPrice") as? SW_CommenFieldRow)?.showErrorLine()
        (form.rowBy(tag: "costPriceTax") as? SW_CommenFieldRow)?.showErrorLine()
        (form.rowBy(tag: "claimPrice") as? SW_CommenFieldRow)?.showErrorLine()
        (form.rowBy(tag: "hourlyWage") as? SW_CommenFieldRow)?.showErrorLine()
    }
    
    @objc private func commitAction(_ sender: UIButton) {
        if boutiquesAccessories.name.isEmpty {
            showAlertMessage("请输入\(type.rawTitle)名称", MYWINDOW)
            showErrorLine()
            return
        }
        if boutiquesAccessories.num.isEmpty {
            showAlertMessage("请输入\(type.rawTitle)编号", MYWINDOW)
            showErrorLine()
            return
        }
        if type == .accessories, boutiquesAccessories.accessoriesTypeId.isEmpty {
            showAlertMessage("请选择配件种类", MYWINDOW)
            return
        } else if type == .boutiques, boutiquesAccessories.boutiqueTypeId.isEmpty {
            showAlertMessage("请选择精品种类", MYWINDOW)
            return
        }
        if boutiquesAccessories.forCarModelType == 2, boutiquesAccessories.carBrand.isEmpty {
            showAlertMessage("请选择车型", MYWINDOW)
            return
        }
        if boutiquesAccessories.warehouseId.isEmpty {
            showAlertMessage("请选择所在仓库", MYWINDOW)
            return
        }
//        if boutiquesAccessories.areaNum.isEmpty {
//            showAlertMessage("请选择仓位号", MYWINDOW)
//            return
//        }
        if boutiquesAccessories.unit.isEmpty {
            showAlertMessage("请选择单位", MYWINDOW)
            return
        }
        if boutiquesAccessories.retailPrice == 0 {
            showAlertMessage("请输入零售价", MYWINDOW)
            showErrorLine()
            return
        }
        if boutiquesAccessories.costPriceTax == 0 {
            showAlertMessage("请输入含税成本价", MYWINDOW)
            showErrorLine()
            return
        }
        if boutiquesAccessories.claimPrice == 0 {
            showAlertMessage("请输入索赔价", MYWINDOW)
            showErrorLine()
            return
        }
        if type == .boutiques, boutiquesAccessories.hourlyWage == 0 {
            showAlertMessage("请输入工时费", MYWINDOW)
            showErrorLine()
            return
        }
        
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在保存", in: self.view)
        /// 如果到这里说明该填的都填了。  --提交修改客户意向 ----
        SW_WorkingService.saveBoutiqueAccessories(type, model: boutiquesAccessories).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                showAlertMessage("保存成功", MYWINDOW)
                self.boutiquesAccessories.id = json["id"].stringValue
                self.navigationController?.pushViewController(SW_BoutiquesAccessoriesDetailViewController(self.boutiquesAccessories, type: self.type, orderId: self.purchaseOrderId), animated: true)
                
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
        })
    }
    
    @objc private func backAction() {
        alertControllerShow(title: "你确定退出此次编辑吗？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
}

extension SW_AddBoutiquesAccessoriesViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
