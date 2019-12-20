//
//  SW_BarCodeScanViewViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BarCodeScanViewViewController: LBXScanViewController {
    
    private var resultBlock: ((String)->Void)?
    private var titleString = ""
//    private var type: ProcurementType = .boutiques
//    private var purchaseOrderId: String = ""
//    private var supplier = ""
//    private var supplierId = ""
    private var lastIsOpenFlash = false
    
    private var topTipLb: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.text = "将条形码放入框内，即可自动扫描"
        lb.font = Font(16)
        return lb
    }()
//    private var bottomTipLb: UILabel = {
//        let lb = UILabel()
//        lb.textColor = .white
//        lb.text = "请确保光线充足和条码清晰；"
//        lb.font = Font(16)
//        return lb
//    }()
    
    private var queryBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "icon_inquire"), for: UIControl.State())
        btn.setTitle("手动查询", for: UIControl.State())
        btn.setTitleColor(.white, for: UIControl.State())
        btn.titleLabel?.font = Font(16)
        btn.imagePosition = .top
        btn.spacingBetweenImageAndTitle = 10
        btn.addTarget(self, action: #selector(queryBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var flashBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "icon_flashlight_off"), for: UIControl.State())
        btn.setImage(#imageLiteral(resourceName: "icon_flashlight_on"), for: .selected)
        btn.setTitle("打开闪光灯", for: UIControl.State())
        btn.setTitle("关闭闪光灯", for: .selected)
        btn.setTitleColor(.white, for: UIControl.State())
        btn.titleLabel?.font = Font(16)
        btn.imagePosition = .top
        btn.spacingBetweenImageAndTitle = 10
        btn.addTarget(self, action: #selector(flashBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var backBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "login_icon_back"), for: UIControl.State())
        btn.addTarget(self, action: #selector(popSelf), for: .touchUpInside)
        return btn
    }()
    
    var titleLb: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = Font(14)
        lb.textAlignment = .center
        return lb
    }()
    
    init(_ resultBlock: ((String)->Void)?, titleString: String = "") {
        super.init(nibName: nil, bundle: nil)
        self.resultBlock = resultBlock
        self.titleString = titleString
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.colorRetangleLine = UIColor.v2Color.blue
        style.colorAngle = UIColor.v2Color.blue
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Outer
        style.photoframeLineW = 4
        style.photoframeAngleW = 50
        style.photoframeAngleH = 50
        style.isNeedShowRetangle = true
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.animationImage = #imageLiteral(resourceName: "scan_icon_line")
        
        //矩形框离左边缘及右边缘的距离
        style.xScanRetangleOffset = isIPad ? 100 : 30
        
        //使用的支付宝里面网格图片
//        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        
        scanStyle = style
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.saveFlashSate()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.restoreFlashSate()
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveFlashSate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Ex.BarCodeScanShouldReStart, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreFlashSate()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.BarCodeScanShouldReStart, object: nil, queue: nil) { [weak self] (notifa) in
            self?.scanObj?.start()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func handleCodeResult(arrayResult:[LBXScanResult])
    {
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:LBXScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)
            
        }else{
            if let result = arrayResult.first,  let str = result.strScanned, str.count > 2 {
                /// 可用的结果
                resultBlock?(str)
            } else {
                /// 不可用的结果，重新开启相机扫描
                /// 相机运行
                scanObj?.start()
            }
        }
    }
    
    @objc func popSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func flashBtnClick(_ sender: QMUIButton) {
        sender.isSelected = !sender.isSelected
        scanObj?.setTorch(torch: sender.isSelected)
    }
    
    @objc func queryBtnClick(_ sender: QMUIButton) {
        navigationController?.pushViewController(SW_ManualInputQueryViewController(resultBlock), animated: true)
    }
    
    private func saveFlashSate() {
        if flashBtn.isSelected {
            scanObj?.setTorch(torch: false)
            flashBtn.isSelected = false
            lastIsOpenFlash = true
        }
    }
    
    private func restoreFlashSate() {
        if lastIsOpenFlash {
            lastIsOpenFlash = false
            dispatch_delay(0.5) {
                self.scanObj?.setTorch(torch: true)
                self.flashBtn.isSelected = true
            }
        }
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension SW_BarCodeScanViewViewController: QRRectDelegate {
    
    func drawwed() {
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(NAV_HEAD_INTERVAL)
            make.height.equalTo(44)
            make.leading.equalTo(0)
            make.width.equalTo(60)
        }
        view.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn)
            make.centerX.equalToSuperview()
        }
        titleLb.text = titleString//
        let margin: CGFloat = isIPad ? 100 : 30
        let w = (SCREEN_WIDTH - margin*2) / 2
        
        view.addSubview(topTipLb)
        topTipLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(SCREEN_HEIGHT/2+w-10)
        }
//        view.addSubview(bottomTipLb)
//        bottomTipLb.snp.makeConstraints { (make) in
//            make.top.equalTo(topTipLb.snp.bottom).offset(8)
//            make.centerX.equalToSuperview()
//        }
        view.addSubview(flashBtn)
        flashBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-80)
            make.width.height.equalTo(100)
            make.top.equalTo(topTipLb.snp.bottom).offset(30)
        }
        view.addSubview(queryBtn)
        queryBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(80)
            make.width.height.equalTo(100)
            make.top.equalTo(topTipLb.snp.bottom).offset(30)
        }
    }
    
    
}
