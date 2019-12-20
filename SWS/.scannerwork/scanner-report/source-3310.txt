//
//  SW_DataShareViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_DataShareViewController: SW_TableViewController {
    /// 共享资料
    private var shareDatas = [SW_DataShareListModel]()
    /// 选择的筛选文章类型
    private var selectArticleType: NormalModel? = nil
    
    lazy var articleTypeBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.imagePosition = .right
        btn.spacingBetweenImageAndTitle = 3
        btn.setTitle("筛 选", for: UIControl.State())
        btn.setTitle("筛 选", for: .selected)
        btn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        btn.setTitleColor(UIColor.v2Color.lightBlack, for: .selected)
        btn.setImage(#imageLiteral(resourceName: "icon_open"), for: UIControl.State())
        btn.setImage(#imageLiteral(resourceName: "icon_unfold"), for: .selected)
        btn.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 3
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(articleTypeBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    /// 选择文章类型的view
    private var selectArticleTypeView: SW_SelectArticleTypeView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_SelectArticleTypeView.self), owner: nil, options: nil)?.first as! SW_SelectArticleTypeView
        return view
    }()
    
    lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "输入查找内容"
        sbar.isCanBecomeFirstResponder = false
        return sbar
    }()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(true)
        }
//        ftv?.isAutomaticallyHidden = false
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    /// 当前总人数
    private var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
        requsetData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: -设置子控件
    private func setupChildView() -> Void {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.ArticleReadCountHadUpdate, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let articleId = notifa.userInfo?["articleId"] as! String
            let readedCount = notifa.userInfo?["readedCount"] as! Int
            if let index = self.shareDatas.firstIndex(where: { return $0.id == articleId }) {
                self.shareDatas[index].readedCount = readedCount
                self.tableView.reloadRow(at: IndexPath(row: index, section: 0), with: .automatic)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeCollectionArticle, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let article = notifa.userInfo?["article"] as! SW_DataShareListModel
            let isCollect = notifa.userInfo?["isCollect"] as! Bool
            if let index = self.shareDatas.firstIndex(where: { return $0.id == article.id }) {
                self.shareDatas[index].isCollect = isCollect
                self.shareDatas[index].collectCount = isCollect ? self.shareDatas[index].collectCount + 1 : self.shareDatas[index].collectCount - 1
                self.tableView.reloadRow(at: IndexPath(row: index, section: 0), with: .automatic)
            }
        }
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.registerNib(SW_DataShareListCell.self, forCellReuseIdentifier: "SW_DataShareListCellID")
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsetData()
            })
        
        
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
        searchBar.backActionBlock = { [weak self] in
            self?.dismissWithAnimation()
            self?.navigationController?.popViewController(animated: true)
        }
        searchBar.becomeFirstBlock = { [weak self] in
            guard let self = self else { return }
            self.dismissWithAnimation()
            //    前往搜索界面
            let vc = SW_SearchShareDataViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        view.addSubview(articleTypeBtn)
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        
        articleTypeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.leading.equalTo(15)
            make.width.equalTo(56)
            make.height.equalTo(29)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(articleTypeBtn.snp.bottom).offset(10)
        }
        
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        tableView.mj_footer = footerView
    }
    
    //    获取当前页面显示数据   后期可能需要添加缓存
    private func requsetData(_ byAppend: Bool = false) {
        let offSet = byAppend ? shareDatas.count : 0
        
        SW_WorkingService.getArticleList(articleTypeId: selectArticleType?.id ?? "", max: 20, offset: offSet).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    let datas = json["list"].arrayValue.map({ (value) -> SW_DataShareListModel in
                        return SW_DataShareListModel(value)
                    })
                    
                    self.shareDatas.append(contentsOf: datas)
                    if self.shareDatas.count >= self.totalCount {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    self.tableView.reloadData()

                } else {
                    self.tableView.mj_header.endRefreshing()
                    let datas = json["list"].arrayValue.map({ (value) -> SW_DataShareListModel in
                        return SW_DataShareListModel(value)
                    })
//                    let datas = [SW_DataShareListModel]()
//                    self.totalCount = 0
                    self.shareDatas = datas
                    /// 加载完毕
                    if self.shareDatas.count < self.totalCount {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                    } else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    }
                    self.tableView.reloadData()
                    if self.shareDatas.count > 0 {
                        self.tableView.scroll(toRow: 0, inSection: 0, at: .top, animated: false)
                    }
                }
            } else {
                if self.shareDatas.count >= self.totalCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    
    @objc private func articleTypeBtnClick(_ sender: QMUIButton) {
        if sender.isSelected {//选中同一个按钮 关闭弹窗
            dismissWithAnimation(true)
            return
        } else {
            sender.isSelected = true
            setButtonHightled(sender: sender)
        }
        setCanDragBack(false)
        selectArticleTypeView.show(selectArticleType, onView: MYWINDOW!, buttonFrame: sender.superview!.convert(sender.frame, to: nil), sureBlock: { [weak self] (selectType) in
            guard let self = self else { return }
            defer {
                self.setCanDragBack(true)
                self.setButtonState()
            }
            guard self.selectArticleType?.id != selectType?.id else {
                return
            }
            self.selectArticleType = selectType
            self.requsetData()
        }) { [weak self] in
            self?.setCanDragBack(true)
            self?.setButtonState()
        }
    }
    
    func dismissWithAnimation(_ animation: Bool = false) {
        setCanDragBack(true)
        selectArticleTypeView.hide(timeInterval: animation ? FilterViewAnimationDuretion : 0, finishBlock: { [weak self] in
            self?.setButtonState()
        })
    }
    
    private func setCanDragBack(_ canDragBack: Bool) {
        if let nav = navigationController as? SW_NavViewController {
            nav.canDragBack = canDragBack
        }
    }
    
    private func setButtonState() {
        articleTypeBtn.isSelected = false
        if selectArticleType != nil {
            articleTypeBtn.setImage(nil, for: UIControl.State())
            articleTypeBtn.setTitleColor(UIColor.white, for: UIControl.State())
            articleTypeBtn.setTitle(selectArticleType!.name, for: UIControl.State())
            articleTypeBtn.backgroundColor = UIColor.v2Color.blue
            articleTypeBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
            articleTypeBtn.layer.borderWidth = 0
        } else {
            articleTypeBtn.setImage(UIImage(named: "icon_open"), for: UIControl.State())
            articleTypeBtn.setTitleColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: UIControl.State())
            articleTypeBtn.setTitle("筛 选", for: UIControl.State())
            articleTypeBtn.backgroundColor = UIColor.white
            articleTypeBtn.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            articleTypeBtn.layer.borderWidth = 0.5
        }
    }
    
    private func setButtonHightled(sender: QMUIButton) {
        sender.backgroundColor = .white
        sender.layer.borderColor = UIColor.clear.cgColor
        sender.layer.borderWidth = 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_DataShareListCellID", for: indexPath) as! SW_DataShareListCell
        cell.model = shareDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = shareDatas[indexPath.row]
        let vc = SW_ArticleWebViewController(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
