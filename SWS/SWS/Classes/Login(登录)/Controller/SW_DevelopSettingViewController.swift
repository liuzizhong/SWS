//
//  SW_DevelopSettingViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_DevelopSettingViewController: UITableViewController, UITextFieldDelegate {
    //  测试区切换开关
    @IBOutlet weak var testEnvironmentSwitch: UISwitch!
    
    @IBOutlet weak var ipField: UITextField!
    
    @IBOutlet weak var portField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testEnvironmentSwitch.isOn = SWSApiCenter.isTestEnvironment
        // Do any additional setup after loading the view.
        ipField.text = SWSApiCenter.localIP
        portField.text = SWSApiCenter.localPort
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fieldChange(_ sender: UITextField) {
        if sender == ipField {
            SWSApiCenter.localIP = ipField.text ?? ""
            
        } else if sender == portField {
            
            SWSApiCenter.localPort = portField.text ?? DefaultPort
        }
    }
    
    @IBAction func testSwitchChange(_ sender: UISwitch) {
        SWSApiCenter.isTestEnvironment = sender.isOn
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    
    @IBAction func checkBaseUrl(_ sender: UIButton) {
        
        showAlertMessage(SWSApiCenter.getBaseUrl(), MYWINDOW)
        
    }
    
}
