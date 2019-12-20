//
//  SW_ConstructionItemFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/5.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_ConstructionItemFormViewController: SW_BaseFormViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    var isInvalid = false
    var isHideAddbtn = false {
        didSet {
            addBtn.isHidden = isHideAddbtn
        }
    }
    var header = ["项目编号","项目名称","工时","项目状态","质检结果"]
    var items = [SW_RepairOrderItemModel]() {
        didSet {
            if items.count > 0 {
                if isInvalid {
                    canSelectItems = []
                } else {
                    canSelectItems = items.filter({ return $0.itemState != .completed && $0.isModify && $0.state == 1 && !$0.isDel  })
                }
                let totalHeight = calculateCellHeight()
                spreadsheetView.isHidden = false
                spreadsheetView.frame = CGRect(x: 0, y: 40, width: SCREEN_WIDTH, height: totalHeight)
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(54 + TABBAR_BOTTOM_INTERVAL + spreadsheetView.frame.maxY))
                noDataLb.isHidden = true
            } else {
                canSelectItems = []
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 40))
            }
            selectItems = []
            spreadsheetView.reloadData()
//            dispatch_delay(0.1) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
//            }
        }
    }
    
    var selectItems = [SW_RepairOrderItemModel]()
    
    var canSelectItems = [SW_RepairOrderItemModel]()
    
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    var addBlock: NormalBlock?
    var addBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("增项", for: UIControl.State())
        btn.setTitleColor(UIColor.white, for: UIControl.State())
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.v2Color.blue
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(addBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    @objc private func addBtnClick(_ sender: UIButton) {
        addBlock?()
    }
    
    private func setup() {
        scrollView.addSubview(spreadsheetView)
//        spreadsheetView.frame = view.bounds
//        scrollView.contentSize = view.bounds.size
        spreadsheetView.frame.origin.y = 40
        scrollView.addSubview(addBtn)
        addBtn.frame = CGRect(x: view.bounds.width - 71, y: 0, width: 56, height: 29)
        spreadsheetView.isScrollEnabled = true
        spreadsheetView.showsHorizontalScrollIndicator = false
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.register(SelectHeaderCell.self, forCellWithReuseIdentifier: String(describing: SelectHeaderCell.self))
        spreadsheetView.register(SelectTextCell.self, forCellWithReuseIdentifier: String(describing: SelectTextCell.self))
    }
    
    // MARK: DataSource
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    private let normalWidth = SCREEN_WIDTH/4
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch column {
        case 0,1:
            return normalWidth + 47
        case 2:
            return normalWidth - 35
        default:
            return normalWidth
        }
    }
    
    /// 记录上次计算d使用的width 相同则
    private var lastCalculateWidth: CGFloat = 0
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        //            canSelectItems.count == 0   靠左   -15   -45
        let width = canSelectItems.count == 0 ? normalWidth + 32 : normalWidth + 2
        for item in items {
            if let height = item.cellHeight, width == lastCalculateWidth {
                totalHeight += height
            } else {
                let cHeight = max(item.repairItemNum.heightWithConstrainedWidth(width, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(normalWidth+47, font: Font(16)) + 24)
                let textH = max(44, cHeight)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        lastCalculateWidth = width
        return totalHeight + 35
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectHeaderCell.self), for: indexPath) as! SelectHeaderCell
                cell.label.text = header[indexPath.column]
                /// 是否全选了
                cell.isSelect = selectItems.count == canSelectItems.count
                cell.imageView.isHidden = canSelectItems.count == 0
                cell.setLabelSnpToLeft(canSelectItems.count == 0)
                return cell
            case header.count - 1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.right)
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.center)
                return cell
            }
        } else {
            let model = items[indexPath.row - 1]
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectTextCell.self), for: indexPath) as! SelectTextCell
                cell.isSelect = selectItems.contains(model)
                cell.isAdd = model.isAppend
                cell.isDel = model.isDel
                cell.imageView.isHidden = !canSelectItems.contains(model)
                cell.setLabelSnpToLeft(canSelectItems.count == 0)
                cell.label.text = model.repairItemNum
                cell.label.numberOfLines = 0
                if model.isDel {
                    cell.label.textColor = UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                }
                return cell
            case header.count - 1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.right)
                cell.label.text = model.qualityState.stateStr
                if model.isDel {
                    cell.label.textColor = UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                }
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = model.name
                case 2:
                    cell.label.text = model.workingHours.toAmoutString()
                default:
                    cell.label.text = model.itemState.stateStr
                }
                if model.isDel {
                    cell.label.textColor = UIColor.v2Color.red.withAlphaComponent(0.5)
                } else {
                    cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                }
                return cell
            }
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            /// 全选全不选
            if selectItems.count == canSelectItems.count {
                selectItems = []
            } else {
                selectItems = canSelectItems
            }
            spreadsheetView.reloadData()
        } else {
            /// 选择取消选择
            let model = items[indexPath.row - 1]
            if canSelectItems.contains(model) {/// 可以选择的
                if let index = selectItems.firstIndex(of: model) {
                    selectItems.remove(at: index)
                    (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectTextCell)?.isSelect = false
                    (spreadsheetView.cellForItem(at: IndexPath(row: 0, column: 0)) as? SelectHeaderCell)?.isSelect = false
                } else {
                    selectItems.append(model)
                    (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectTextCell)?.isSelect = true
                    if selectItems.count == canSelectItems.count {
                        (spreadsheetView.cellForItem(at: IndexPath(row: 0, column: 0)) as? SelectHeaderCell)?.isSelect = true
                    }
                }
            } else {/// 不能选择的
                return
            }
        }
    }
}


class SelectHeaderCell: Cell {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Main_unselect"))
    
    var isSelect = false {
        didSet {
            imageView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        let line = UIView()
        
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.v2Color.lightGray
        label.textAlignment = .left
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.trailing.bottom.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        contentView.backgroundColor = .white
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// 设置label 左边对齐
    func setLabelSnpToLeft(_ isLeft: Bool) {
        if isLeft {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(15)
                make.top.trailing.bottom.equalToSuperview()
            }
        } else {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(imageView.snp.trailing).offset(10)
                make.top.trailing.bottom.equalToSuperview()
            }
        }
    }
}

class SelectTextCell: Cell {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Main_unselect"))
    
    let addImageView = UIImageView(image: #imageLiteral(resourceName: "work_repairmanagement_icon_add"))
    
    let delImageView = UIImageView(image: #imageLiteral(resourceName: "repairOrder_icon_delete"))
    
    var isAdd = false {
        didSet {
            addImageView.isHidden = !isAdd
        }
    }
    
    var isDel = false {
        didSet {
            delImageView.isHidden = !isDel
        }
    }
    
    var isSelect = false {
        didSet {
            imageView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        addImageView.isHidden = true
        contentView.addSubview(addImageView)
        addImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
        }
        
        delImageView.isHidden = true
        contentView.addSubview(delImageView)
        delImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-5)
            make.leading.equalTo(4)
        }
        
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.v2Color.lightBlack
        label.textAlignment = .left
        
        let line = UIView()
        
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.trailing.bottom.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 设置label 左边对齐
    func setLabelSnpToLeft(_ isLeft: Bool) {
        if isLeft {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(15)
                make.top.trailing.bottom.equalToSuperview()
            }
        } else {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(imageView.snp.trailing).offset(10)
                make.top.trailing.bottom.equalToSuperview()
            }
        }
    }
}

class SelectFieldCell: Cell, QMUITextFieldDelegate {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "Main_unselect"))
    
    var isAmount: Bool?
    
    var amountMax: Double?
    
    var limitCount: Int?
    /// 能输入的有效小数位数
    var decimalCount = 2
//
//    var count: Double = 1.0 {
//        didSet {
//            field.placeholder = "\(count)"
//        }
//    }
    
    var isSelect = false {
        didSet {
            imageView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    var textChangeBlock: ((String)->Void)?
    
    let field = QMUITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        field.shouldResponseToProgrammaticallyTextChanges = false
        field.delegate = self
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        field.keyboardType = .decimalPad
        field.layer.cornerRadius = 3
        field.layer.borderColor = UIColor.v2Color.disable.cgColor
        field.layer.borderWidth = 0.5
        field.font = UIFont.systemFont(ofSize: 16)
        field.textColor = UIColor.v2Color.lightBlack
        field.textAlignment = .center
        field.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let line = UIView()
        
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        contentView.addSubview(field)
        field.snp.makeConstraints { (make) in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(62)
            make.height.equalTo(28)
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        textChangeBlock?(textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {///限制不能全输入空格,必须要有非空格的内容
            return false
        }
        if  isAmount == true {//金额输入框 ----
            let isHaveDian = textField.text?.contains(".") ?? false
            let isFirstZero = (textField.text?.firstString() == "0")
            
            if let max = amountMax {//有限制最大值  判断输入的值是否超出范围
                let text: NSString = (textField.text  ?? "") as NSString
                if let amount = Double(text.replacingCharacters(in: range, with: string)), amount > max {
                    return false
                }
            }
            
            if string.count > 0 {//有输入
                let single = string.firstString()//当前输入的字符
                if "0123456789.".contains(single) {//可以输入的内容
                    if textField.text?.count == 0 {//输入第一个字符
                        if single == "." {//首字母不能为小数点
                            return false
                        }
                        return true//第一位只有.不能输入
                    }
                    //已经有输入内容
                    if single == "." {
                        if isHaveDian {
                            return false
                        } else {//text中还没有小数点
                            return true
                        }
                    } else {
                        if isHaveDian {//存在小数点，保留两位小数
                            //首位有0有.（0.01）或首位没0有.（10200.00）可输入两位数的0
                            if textField.text == "0.0",single == "0" {///不能输入0.00
                                return false
                            }
                            if let dianRange = (textField.text as NSString?)?.range(of: "."), range.location <= dianRange.location {//有小数点，但输入的范围是整数部分，可以输入
                                return true
                            }
                            //用。分割后计算后面的个数 =====-----decimal  小数点后面的字符
                            let decimal = textField.text?.components(separatedBy: ".").last ?? ""
                            return decimal.count <  decimalCount 
                        } else if isFirstZero && !isHaveDian {//首位有0没点 不能输入了  金额就是0了
                            return false
                        } else {///其余可以直接输入
                            return true
                        }
                    }
                } else {//输入错误字符
                    return false
                }
            } else {
                return true
            }
        } else if let limit = limitCount {//设置了限制长度
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > limit {
                return false
            }
            return true
        }
        return true
    }
    
    
}
