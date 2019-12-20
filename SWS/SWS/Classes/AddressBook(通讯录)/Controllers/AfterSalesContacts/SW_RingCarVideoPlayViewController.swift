//
//  SW_RingCarVideoPlayViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/18.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import BMPlayer
import AVFoundation
import NVActivityIndicatorView

class SW_RingCarVideoPlayViewController: UIViewController {
    
    var player: BMPlayer!
    
    private var videoUrl: URL!
    
    private var allKeyProblem = [SW_RingCarKeyFrameModel]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    init(_ url: URL, allKeyProblem: [SW_RingCarKeyFrameModel]) {
        super.init(nibName: nil, bundle: nil)
        self.videoUrl = url
        self.allKeyProblem = allKeyProblem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerManager()
        preparePlayer()
        setupPlayerResource()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func applicationWillEnterForeground() {
        
    }
    
    @objc func applicationDidEnterBackground() {
        player.pause(allowAutoPlay: false)
    }
    
    /**
     prepare playerView
     */
    func preparePlayer() {
        player = BMPlayer(customControlView: nil)
        view.addSubview(tableView)
        view.addSubview(player)
        
        player.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0).priority(500)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
           make.top.equalTo(player.snp.bottom)
            /// 或者固定高度
        }
        
        
        player.delegate = self
        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen {
                return
            } else {
//                let _ = self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    
    
    func setupPlayerResource() {
//        let asset = self.preparePlayerItem()
        let asset = BMPlayerResource(url: videoUrl, name: "环车检视")
//        player.setVideo(resource: asset)
        player.setVideo(resource: asset)
    }
    
    // 设置播放器单例，修改属性
    func setupPlayerManager() {
        resetPlayerManager()
       
            // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
//            BMPlayerConf.shouldAutoPlay = false
        
            // 设置播放器属性，此情况下若提供了cover则先展示封面图，否则黑屏。点击播放后开始loading
//            BMPlayerConf.topBarShowInCase = .always
//
//
//            BMPlayerConf.topBarShowInCase = .horizantalOnly
//
//
//            BMPlayerConf.topBarShowInCase = .none
        
    }
    
    
    /**
     准备播放器资源model
     */
//    func preparePlayerItem() -> BMPlayerResource {
//        let res0 = BMPlayerResourceDefinition(url: URL(string: "https://www.bilibili.com/f8f64bd2-231b-4fef-91d9-b6ec56780732")!,
//                                              definition: "高清")
//        let res1 = BMPlayerResourceDefinition(url: URL(string: "https://www.bilibili.com/f8f64bd2-231b-4fef-91d9-b6ec56780732")!,
//                                              definition: "标清")
//
//        let asset = BMPlayerResource(name: "周末号外丨中国第一高楼",
//                                     definitions: [res0, res1],
//                                     cover: URL(string: "https://www.bilibili.com/f8f64bd2-231b-4fef-91d9-b6ec56780732"))
//        return asset
//    }
    
    
    func resetPlayerManager() {
        #if DEBUG
        //调试模式
        BMPlayerConf.allowLog = true
        #else
        BMPlayerConf.allowLog = false
        #endif
        BMPlayerConf.shouldAutoPlay = true
        BMPlayerConf.tintColor = UIColor.white
        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法
        player.pause(allowAutoPlay: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法
        player.autoPlay()
    }
    
    deinit {
        // If use the slide to back, remember to call this method
        // 使用手势返回的时候，调用下面方法手动销毁
        player.prepareToDealloc()
        NotificationCenter.default.removeObserver(self)
        print("VideoPlayViewController Deinit")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// MARK:- BMPlayerDelegate example
extension SW_RingCarVideoPlayViewController: BMPlayerDelegate {
    // Call when player orinet changed
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            if isFullscreen {
                make.bottom.equalTo(view.snp.bottom)
            } else {
                make.height.equalTo(view.snp.width).multipliedBy(9.0/16.0).priority(500)
            }
        }
    }
    
    // Call back when playing state changed, use to detect is playing or not
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
    }
    
    // Call back when play time change
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        //        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
    }
    
    // Call back when the video loaded duration changed
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        //        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
    }
}

extension SW_RingCarVideoPlayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allKeyProblem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(allKeyProblem[indexPath.row].time)"
        cell.detailTextLabel?.text = allKeyProblem[indexPath.row].keyProblem
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        player.seek(TimeInterval(exactly: allKeyProblem[indexPath.row].time) ?? TimeInterval(bitPattern: 0))
        player.pause()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
}
