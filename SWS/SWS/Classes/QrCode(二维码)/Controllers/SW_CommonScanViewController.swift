//
//  SW_CommonScanViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

enum QrCodeType: Int {
    case none = 0
    case login
    case accessoriesReceive
    case boutiqueReceive
    case accessoriesBack
    case boutiqueBack
    ///  维修配件 6 出库 8 返库
    case repairAccessoriesOut
    case repairBoutiqueOut
    case repairAccessoriesBack
    case repairBoutiqueBack
    ///  展车精品 10 出 11 返
    case playCarBoutiqueOut
    case playCarBoutiqueBack
    ///  合同精品 12 出 13 返
    case contractBoutiqueOut
    case contractBoutiqueBack
    
    //内部领件： "配件领件"、"精品领件"
    //内部返库："配件领件返库"、"精品领件返库"
    //维修领件："维修配件领件" 、"维修精品领件"
    //维修返库："维修配件返库" 、"维修精品返库"
    //展车精品："展车精品领件" 、"展车精品返库"
    //合同精品："合同精品领件" 、"合同精品返库"
    var navTitle: String {
        switch self {
        case .contractBoutiqueOut:
            return "合同精品领件"
        case .contractBoutiqueBack:
            return "合同精品返库"
        case .playCarBoutiqueOut:
            return "展车精品领件"
        case .playCarBoutiqueBack:
            return "展车精品返库"
        case .repairAccessoriesOut:
            return "维修配件领件"
        case .repairAccessoriesBack:
            return "维修配件返库"
        case .repairBoutiqueOut:
            return "维修精品领件"
        case .repairBoutiqueBack:
            return "维修精品返库"
        case .accessoriesReceive:
            return "配件领件"
        case .accessoriesBack:
            return "配件领件返库"
        case .boutiqueReceive:
            return "精品领件"
        case .boutiqueBack:
            return "精品领件返库"
        default:
            return ""
        }
    }
}

class SW_CommonScanViewController: LBXScanViewController {
    
    private var resultBlock: ((String)->Void)?
    private var titleString = ""
    private var lastIsOpenFlash = false
    
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
        
        //        isOpenInterestRect = true
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
            
            self.navigationController?.popViewController(animated: true)
            let result:LBXScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)
            
        }else{
            if let result = arrayResult.first,  let str = result.strScanned {
                
                if resultBlock != nil {//如果传入有block则调用block
                    /// 可用的结果
                    resultBlock?(str)
                } else {
                    /// 控制器默认处理
                    let qrJson = JSON(parseJSON: str)
                    let type = QrCodeType(rawValue: qrJson["codeType"].intValue) ?? .none
                    var isUseId = false
                    switch type {
                        
                    case .playCarBoutiqueBack,.playCarBoutiqueOut,.contractBoutiqueOut,.contractBoutiqueBack:
                        isUseId = true
                        fallthrough
                    case .accessoriesReceive, .boutiqueReceive, .accessoriesBack, .boutiqueBack, .repairAccessoriesOut, .repairAccessoriesBack, .repairBoutiqueOut, .repairBoutiqueBack:
//                        "operatorId" : "3",
//                        "data" : {
//                            "orderNum" : "LJ201906140000872",
//                            "id" : "402881f46b55a0d8016b561cca4f0028"
//                        },
//                        "key" : "e2221593-fea2-4eaa-af43-a9149ba0f942",
//                        "codeType" : 2
                       let id = qrJson["data"]["id"].stringValue
                       let orderNum = qrJson["data"]["orderNum"].stringValue
                       let operatorId = qrJson["operatorId"].intValue
                       let qrKey = qrJson["key"].stringValue
                       let itemFlagStr = isUseId ? id : orderNum
                       SW_QrCodeService.qrCodeUpdateState(qrKey, type: type, itemFlagStr: itemFlagStr).response({ (json, isCache, error) in
                            if let _ = json as? JSON, error == nil {
                                /// 去确定领件页面
                                self.navigationController?.pushViewController(SW_AccessBoutiqueReceiveViewController(type: type, qrKey: qrKey, id: id, orderNum: orderNum, operatorId: operatorId), animated: true)
                            } else {
                                self.scanObj?.start()
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                            }
                        })
                        break
                    default:
                        showAlertMessage("二维码无效", MYWINDOW)
                        scanObj?.start()
                        break
                    }
                }
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
    
//    @objc func queryBtnClick(_ sender: QMUIButton) {
//        navigationController?.pushViewController(SW_ManualInputQueryViewController(resultBlock), animated: true)
//    }
    
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

extension SW_CommonScanViewController: QRRectDelegate {
    
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
        
        view.addSubview(flashBtn)
        flashBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
            make.top.equalTo(SCREEN_HEIGHT/2+w+20)
        }
    }
    
    
}

