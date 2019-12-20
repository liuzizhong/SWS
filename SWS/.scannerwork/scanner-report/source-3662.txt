//
//  SW_RingCarRecorderViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/9.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import CoreTelephony

class SW_RingCarRecorderViewController: UIViewController {
    /// 环车检视频最大录制时间
    let maxVideoDuration = 180
    
    private var callCenter = CTCallCenter()
    
    private var lastVideoPath = ""
    
    private var allKeyProblem = [SW_RingCarKeyFrameModel]()
    
    private lazy var recorder: ALiVideoRecorder = {
        let rcder = ALiVideoRecorder()
        rcder.maxVideoDuration = self.maxVideoDuration///单位s
        rcder.delegate = self
        rcder.previewLayer()?.connection?.videoOrientation = .landscapeRight
        rcder.previewLayer()?.frame = self.view.bounds
        self.view.layer .insertSublayer(rcder.previewLayer(), at: 0)
        return rcder
    }()
    
    private var backBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "nav_back"), for: UIControl.State())
        btn.addTarget(self, action: #selector(popSelf), for: .touchUpInside)
        return btn
    }()
    
    private var timeLabel: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .black
        lb.font = Font(14)
        lb.textColor = .white
        lb.layer.cornerRadius = 5
        return lb
    }()
    
    private var recorderBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "editor_video_start_normal"), for: UIControl.State())
        btn.setImage(#imageLiteral(resourceName: "editor_video_start_selected"), for: .selected)
        btn.addTarget(self, action: #selector(recorderBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var pauseBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "pause"), for: UIControl.State())
        btn.setImage(#imageLiteral(resourceName: "play"), for: .selected)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(pauseBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        
        return imgV
    }()
    
    private var isToKeyFrame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        setup()
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isToKeyFrame {
            recorder.openPreview()
        } else {
            isToKeyFrame = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackgroundMode), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if !isToKeyFrame {
            recorder.closePreview()
        }
    }
    
    //MARK: - private func
    private func setup() {
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.height.equalTo(60)
            make.leading.equalTo(0)
            make.width.equalTo(100)
        }
        
        view.addSubview(recorderBtn)
        recorderBtn.snp.makeConstraints { (make) in
//            make.leading.equalTo(15)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-5)
            make.width.height.equalTo(60)
        }
        
        view.addSubview(pauseBtn)
        pauseBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(recorderBtn.snp.trailing).offset(15)
            make.centerY.equalTo(recorderBtn.snp.centerY)
            make.width.height.equalTo(60)
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
        }
//        view.addSubview(imageView)
//        imageView.snp.makeConstraints { (make) in
//            make.top.trailing.equalToSuperview()
//            make.width.equalTo(124)
//            make.height.equalTo(74)
//        }
        
        view.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            if let tap = gesture as? UITapGestureRecognizer {
                let point = tap.location(in: self?.view)
                self?.recorder.setFocusCursorWith(point)
            }
        })
       ///
        callCenter.callEventHandler = { [weak self] (call:CTCall!) in
            switch call.callState {
            case CTCallStateIncoming:
                self?.stopRecording(true)
            default:
                //Not concerned with CTCallStateDialing or CTCallStateIncoming
                break
            }
        }
    }
//         意外结束流程
//         “录制已结束”
//    “使用视频”   “重新录制”
//    添加意外情况z停止录制，提示“录制已经强制结束，是否需要重新录制。”
//    重新录制时：  本来视频文件要删除，keyframe数组要清空，lastVideoPath 也要清空
    func stopRecording(_ isException: Bool = false) {
        guard recorder.isCapturing,
            !recorder.videoPath.isEmpty,
            recorder.assetWriter != nil else { return }
        recorderBtn.isSelected = false
        pauseBtn.isHidden = true
        pauseBtn.isSelected = false
        ALiUtil.playSystemTipAudioIsBegin(false)
        recorder.stopRecordingCompletion { [weak self] (movieImage) in
            guard let self = self else { return }
            /// 录制完成后，跳转至预览视频与记录界面。
            self.lastVideoPath = self.recorder.videoPath
            
            PrintLog("Videoduretion:\(self.recorder.getVideoLength(URL(fileURLWithPath: self.recorder.videoPath)))--FileSize:\(self.recorder.getFileSize(self.recorder.videoPath))")
            let url = URL(fileURLWithPath: self.recorder.videoPath)
            let vc = SW_RingCarVideoPlayViewController(url, allKeyProblem: self.allKeyProblem)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
            
        }
        
    }
    
    /// 相当于run
    @objc private func checkDiskSpace() -> Bool {
        let leftSpace = ALiUtil.diskFreeSpace()
        if leftSpace<150 {//少于150直接提示空间不足，不录制
            SW_UserCenter.shared.showAlert(message: "存储空间不足,无法进行视频录制", str: "我知道了") { (_) in
                self.popSelf()
            }
            return false
        }
        return true
    }
    
    @objc func popSelf(_ force: Bool = false) {
        /// 判断有录制的视频需要弹窗提示
        if (self.recorder.isCapturing) {
            if force {
                //正在录制 停止录制删除缓存
                self.recorder.unloadInputOrOutputDevice()
                self.recorder.cleanCache()
                self.dismiss(animated: true, completion: nil)
            } else {
                alertControllerShow(title: "你要放弃本次录像以及记录吗？", message: nil, rightTitle: "确定", rightBlock: { (_, _) in
                    //正在录制 停止录制删除缓存
                    self.recorder.unloadInputOrOutputDevice()
                    self.recorder.cleanCache()
                    self.dismiss(animated: true, completion: nil)
                }, leftTitle: "取消", leftBlock: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func recorderBtnClick(_ sender: QMUIButton) {
        if (!self.recorder.isCapturing) {
            if checkDiskSpace() {/// 空间足够则开始录制
                sender.isSelected = true
                pauseBtn.isHidden = false
                ALiUtil.playSystemTipAudioIsBegin(true)
                recorder.recordOrientation = .landscapeRight
                recorder.adjust(.landscapeRight)
                recorder.startRecording()
            }
        } else {
            stopRecording()
        }
        
    }
    
    //监听刚进入后台 推荐如果正在录制则停止 如果未开始录制则返回上一个界面
    @objc func enterBackgroundMode() {
        //进入后台
        if (self.recorder.isCapturing && !self.recorder.isPaused) {
            dispatch_async_main_safe {
                self.stopRecording(true)/// 这里停止录制 属于意外停止。
            }
        } else {
            //非暂停状态 暂停状态不做任何操作
            dispatch_async_main_safe {
                self.popSelf(true)
            }
        }
    }
    
    
    
    @objc func pauseBtnClick(_ sender: QMUIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            recorder.pauseRecording()
            /// 暂停录制时，获取最后一帧的图片，跳转至输入记录页面。
//            imageView.image = recorder.pauseImage
            
            isToKeyFrame = true
            let nav = SW_NavViewController.init(rootViewController: SW_RingCarKeyFrameViewController.creatVc(sureBlock: { [weak self] (text) in
                guard let self = self else { return }
                self.allKeyProblem.append(SW_RingCarKeyFrameModel.init(time: self.recorder.currentRecordTime,keyProblem: text))
            }))
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        } else {
            recorder.resumeRecording()
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SW_RingCarRecorderViewController: ALiVideoRecordDelegate {
    func recordProgress(_ progress: CGFloat) {
        /// 剩余的秒数
        let time = Int(ceil((1-progress) * CGFloat(recorder.maxVideoDuration)))
//        let second = time%60
//        let minute = time/60
//        timeLabel.text = String(format: "%02ld : %02ld",minute,second)
        timeLabel.text = "剩余:\(time)s"
//        添加进度条
        if progress >= 1 {// 录制完成，
            stopRecording()
        }
    }
    
    
}
