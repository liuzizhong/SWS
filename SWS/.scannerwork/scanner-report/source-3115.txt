//
//  SW_CreatGroupViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CreatGroupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var headerView: SW_CreatGroupHeaderView = {
        let view = Bundle.main.loadNibNamed("SW_CreatGroupHeaderView", owner: nil, options: nil)?.first as! SW_CreatGroupHeaderView
        return view
    }()
    
    private let rangeCellId = "sw_creatGroupCellId"
    
    private var rangeManager: SW_RangeManager!
    
    private var currentList = [SW_RangeModel]()
    
    private var isRequesting = false
    
    private var hadShowGroupName = false
    
    class func ctreatVc(_ manager: SW_RangeManager) -> SW_CreatGroupViewController {
        let vc = UIStoryboard(name: "Range", bundle: nil).instantiateViewController(withIdentifier: "SW_CreatGroupViewController") as! SW_CreatGroupViewController
        vc.rangeManager = manager
        vc.currentList = manager.selectStaffs
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_delay(0.05) {
            if !self.hadShowGroupName {
                self.hadShowGroupName = true
                self.showChangeGroupNameAlert()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setUp() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(sureBtnAction(_:)))
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        tableView.tableFooterView = UIView()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 256))
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 256)
        view.addSubview(headerView)
        tableView.tableHeaderView = view
        
        headerView.selectCountLb.text = "已选择:\(rangeManager.selectStaffs.count)/500人"
        headerView.editIconBlock = { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
            SW_ImagePickerHelper.shared.showPicturePicker( { (image) in
                self.headerView.iconImageView.image = image
            })
        }
        headerView.editNameBlock = { [weak self] in
            self?.showChangeGroupNameAlert()
        }
        
    }

    
    @objc func sureBtnAction(_ sender: UIBarButtonItem) {
        guard let groupName = headerView.nameField.text, !groupName.isEmpty else {
            showAlertMessage("请输入工作群名称", view)
            return
        }
        guard let iconImage = headerView.iconImageView.image else {
            self.creatGroup(name: groupName, key: "")/// 没有图片、
            return
        }
        handleImage(iconImage, name: groupName)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    deinit {
        PrintLog("dddeinit ")
    }
    
    private func showChangeGroupNameAlert() {
        let nameAlert = UIAlertController.init(title: InternationStr("请输入群名称"), message: nil, preferredStyle: .alert)
        var field: UITextField!
        nameAlert.addTextField { (textfield) in
            field = textfield
            textfield.placeholder = InternationStr("群名称")
            textfield.keyboardType = .default
            textfield.clearButtonMode = .whileEditing
            textfield.borderStyle = .roundedRect
        }
        field.text = headerView.nameField.text
        
        let sure = UIAlertAction(title: "确认", style: .default, handler: { [weak self] action in
            self?.headerView.nameField.text = field.text
//            if let text = field.text , !text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
//                guard let sSelf = self else { return }
//            } else {
//                showAlertMessage(InternationStr("群名称不可以为空"), MYWINDOW)
//            }
        })
        nameAlert.addAction(sure)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        nameAlert.addAction(cancel)
        
        present(nameAlert, animated: true, completion: nil)
        nameAlert.clearTextFieldBorder()
    }
    
    //最后的处理  上传图片  上传服务器 然后创建工作群
    private func handleImage(_ selectImage: UIImage, name: String) {
        guard !isRequesting else { return }
        QMUITips.showLoading("正在创建", in: self.view)
        isRequesting = true
        //上传至七牛后，将七牛返回的key上传至服务端。
        SWSUploadManager.share.upLoadPortrait(selectImage) { (success, key) in
            if let key = key, success {
                self.creatGroup(name: name, key: key)
            } else {
                QMUITips.hideAllTips(in: self.view)
                self.isRequesting = false
            }
        }
    }
    
    private func creatGroup(name: String, key:String) {
        SW_GroupService.saveGroup(SW_UserCenter.shared.user!.id, groupName: name, staffIds: self.rangeManager.getSelectPeopleIdStr(), imageUrl: key).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("创建群成功", self.view)
                self.dismiss(animated: true, completion: nil)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
        })
    }
}

extension SW_CreatGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        cell.rangeModel = currentList[indexPath.row]
        cell.isHiddenSelect = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
}

extension SW_CreatGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        let textcount = textField.text?.count ?? 0
        if string.count + textcount - range.length > 20 {
            return false
        }
        return true
    }
}
