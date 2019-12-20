//
//  SW_SelectRangeSearchBar.swift
//  SWS
//
//  Created by jayway on 2018/12/3.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectRangeSearchBar: UIView {
    
    @IBOutlet weak var searchBgView: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    var placeholderString: String? {
        didSet {
            textField.placeholder = placeholderString
        }
    }
    
    @IBOutlet weak var regionBtn: QMUIButton!
    
    @IBOutlet weak var bunitBtn: QMUIButton!
    
    @IBOutlet weak var deptBtn: QMUIButton!
    
    @IBOutlet var options: [QMUIButton]!
    
    /// 是否可以直接搜索
    var isCanBecomeFirstResponder: Bool = true
    
    private var rangeManager: SW_RangeManager = {
        let manager = SW_RangeManager()/// 默认选择自己所在的分区和单位
        let reg = SW_RangeModel()
        reg.type = .region
        reg.id = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        reg.regStr = SW_UserCenter.shared.user!.regionInfo
        manager.selectRegs = [reg]
        let bunit = SW_RangeModel()
        bunit.type = .business
        bunit.id = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        bunit.regId = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        bunit.businessName = SW_UserCenter.shared.user!.businessUnitName
        manager.selectBuses = [bunit]
        return manager
    }()
    
    /// 约束 动画改变
    @IBOutlet weak var textFieldLeftConstraint: NSLayoutConstraint!
    
    /// 选择范围的view
    private lazy var selectRangeView: SW_SelectRangeView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_SelectRangeView.self), owner: nil, options: nil)?.first as! SW_SelectRangeView
        return view
    }()
    
    /// action block
    var becomeFirstBlock: NormalBlock?
    
    var searchBlock: NormalBlock?
    
    var textChangeBlock: NormalBlock?
    
    var rangeChangeBlock: NormalBlock?
    
    var searchText: String {
        get {
            return textField.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBgView.addShadow()
        options.forEach { (btn) in
            btn.imagePosition = .right
        }
        layer.shadowOpacity = 0
        searchBgView.layer.cornerRadius = 3
        setButtonState()
        /// 
        selectRangeView.realRangeManager = rangeManager
    }
    
    //MARK: - 按钮点击事件
    @IBAction func searchBgClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        if isCanBecomeFirstResponder {
            myBecomeFirstResponder()
        }
        dismissWithAnimation()
        becomeFirstBlock?()
    }
    
    //MARK: - 内部动画、逻辑
    func myBecomeFirstResponder() {
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
    }
    
    func myResignFirstResponder() {
        textField.resignFirstResponder()
        textField.text = ""
        textField.isUserInteractionEnabled = false
    }
    
    @IBAction func textfieldEditingChanged(_ sender: UITextField) {
        textChangeBlock?()
    }
    
    var selectButton: QMUIButton?
    
    @IBAction func regionBtnClick(_ sender: QMUIButton) {
        textField.resignFirstResponder()
        if sender == selectButton {//选中同一个按钮 关闭弹窗所有
            dismissWithAnimation(true)
            return
        } else {
            dismissWithAnimation()
            setButtonHightled(sender: sender)
        }
        
        selectRangeView.show(rangeManager, pageType: .region, onView: MYWINDOW!, buttonFrame: sender.superview!.convert(sender.frame, to: nil), sureBlock: { [weak self] (rangeManager) in
            guard let self = self else { return }
            self.rangeManager.selectRegs = rangeManager.selectRegs
            self.rangeManager.selectBuses = []
            self.rangeManager.selectDeps = []
            self.selectRangeView.realRangeManager = self.rangeManager
            self.setButtonState()
            self.rangeChangeBlock?()
        }) { [weak self] in
            self?.setButtonState()
        }
    }
    
    @IBAction func bunitBtnClick(_ sender: QMUIButton) {
        textField.resignFirstResponder()
        if sender == selectButton {//选中同一个按钮 关闭弹窗所有
            dismissWithAnimation(true)
            return
        } else {
            dismissWithAnimation()
            setButtonHightled(sender: sender)
        }
        
        selectRangeView.show(rangeManager, pageType: .business, onView: MYWINDOW!, buttonFrame: sender.superview!.convert(sender.frame, to: nil), sureBlock: { [weak self] (rangeManager) in
            guard let self = self else { return }
            self.rangeManager.selectBuses = rangeManager.selectBuses
            self.rangeManager.selectDeps = []
            self.selectRangeView.realRangeManager = self.rangeManager
            self.setButtonState()
            self.rangeChangeBlock?()
        }) { [weak self] in
            self?.setButtonState()
        }
    }
    
    @IBAction func deptBtnClick(_ sender: QMUIButton) {
        textField.resignFirstResponder()
        if sender == selectButton {//选中同一个按钮 关闭弹窗所有
            dismissWithAnimation(true)
            return
        } else {
            dismissWithAnimation()
            setButtonHightled(sender: sender)
        }
        
        selectRangeView.show(rangeManager, pageType: .department, onView: MYWINDOW!, buttonFrame: sender.superview!.convert(sender.frame, to: nil), sureBlock: { [weak self] (rangeManager) in
            guard let self = self else { return }
            self.rangeManager.selectDeps = rangeManager.selectDeps
            self.setButtonState()
            self.rangeChangeBlock?()
        }) { [weak self] in
            self?.setButtonState()
        }
    }
    
    func setButtonState() {
        setButton(sender: deptBtn, isBlue: rangeManager.selectDeps.count > 0)
        setButton(sender: bunitBtn, isBlue: rangeManager.selectBuses.count > 0)
        setButton(sender: regionBtn, isBlue: rangeManager.selectRegs.count > 0)
        
        deptBtn.isHidden = rangeManager.selectBuses.count == 0
        bunitBtn.isHidden = rangeManager.selectRegs.count == 0
    }
    
    private func setButton(sender: QMUIButton, isBlue: Bool) {
        if isBlue {
            sender.setImage(UIImage(named: "icon_open_select"), for: UIControl.State())
            sender.setTitleColor(UIColor.white, for: UIControl.State())
            sender.backgroundColor = UIColor.v2Color.blue
            sender.layer.cornerRadius = 3
            sender.layer.borderColor = UIColor.v2Color.blue.cgColor
            sender.layer.borderWidth = 0
        } else {
            sender.setImage(UIImage(named: "icon_open"), for: UIControl.State())
            sender.setTitleColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: UIControl.State())
            sender.backgroundColor = UIColor.white
            sender.layer.cornerRadius = 3
            sender.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            sender.layer.borderWidth = 0.5
        }
    }
    
    private func setButtonHightled(sender: QMUIButton) {
        selectButton = sender
        sender.setImage(UIImage(named: "icon_unfold"), for: UIControl.State())
        sender.setTitleColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: UIControl.State())
        sender.backgroundColor = UIColor.white
        sender.layer.borderColor = UIColor.clear.cgColor
        sender.layer.borderWidth = 0
    }
    
    func dismissWithAnimation(_ animation: Bool = false) {
        selectButton = nil
        selectRangeView.hide(timeInterval: animation ? FilterViewAnimationDuretion : 0, finishBlock: { [weak self] in
            self?.setButtonState()
        })
    }
    
    func getTypeAndIdStr() -> (Int,String){
        // 当type=3,idStr为:单位id_部门id;
        // 当type=4,idStr为:分区id_单位id;
        // 当type=5,idStr为:分区id",
        // 当type=6,idStr为:""空 ",
        if rangeManager.selectDeps.count > 0 {
            let idStr =  rangeManager.selectDeps.map({ (model) -> String in
                return "\(model.busId)_\(model.id)"
            }).joined(separator: ",")
            return (3,idStr)
        }
        if rangeManager.selectBuses.count > 0 {
            let idStr = rangeManager.selectBuses.map({ (model) -> String in
                return "\(model.regId)_\(model.id)"
            }).joined(separator: ",")
            return (4,idStr)
        }
        if rangeManager.selectRegs.count > 0 {
            let idStr = rangeManager.selectRegs.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
            return (5,idStr)
        }
        return (6,"")
    }
    
}

extension SW_SelectRangeSearchBar: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dismissWithAnimation()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchBlock = searchBlock else { return true }
        textField.resignFirstResponder()
        searchBlock()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textField.resignFirstResponder()
    }
}
