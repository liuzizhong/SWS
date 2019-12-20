//
//  SW_LocationViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/10.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

@objc protocol SW_LocationViewControllerDelegate: NSObjectProtocol {
    
    func sendLocationLatitude(_ latitude: Double, longitude: Double, addressJsonString: String)
    
}

/// 选择位置发送的控制器
class SW_LocationViewController: UIViewController {
    @objc weak var delegate: SW_LocationViewControllerDelegate?
    var navBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    var titleLb: UILabel = {
        let lb = UILabel()
        lb.text = "位置"
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.textColor = UIColor.v2Color.lightBlack
        return lb
    }()
    var cancelBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("取消", for: UIControl.State())
        btn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        btn.titleLabel?.font = Font(14)
        btn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    var sendBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("发送", for: UIControl.State())
        btn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        btn.titleLabel?.font = Font(14)
        btn.addTarget(self, action: #selector(sendBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    /// 关键词搜索对象
    lazy var search: AMapSearchAPI = {
        let s = AMapSearchAPI()!
        s.delegate = self
        return s
    }()
    /// 周边POI搜索对象
    lazy var searchPoi: AMapSearchAPI = {
        let s = AMapSearchAPI()!
        s.delegate = self.tableView
        return s
    }()
    /// 地图view
    lazy var mapView: MAMapView = {
        let mView = MAMapView(frame: CGRect.zero)
        mView.mapType = .standard
        mView.delegate = self
        mView.isRotateEnabled = false
        mView.distanceFilter = 50
        mView.touchPOIEnabled = false
        mView.showsUserLocation = true
//        mView.runLoopMode = RunLoopMode.defaultRunLoopMode//NSDefaultRunLoopMode
        let representation = MAUserLocationRepresentation()
        representation.locationDotFillColor = UIColor.v2Color.blue
        mView.update(representation)
        return mView
    }()
    lazy var searchBgView: QMUIButton = {
        let view = QMUIButton(type: .custom)
        view.highlightedBackgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        view.layer.cornerRadius = 3
        view.backgroundColor = .white
        view.addTarget(self, action: #selector(myBecomeFirstResponder), for: .touchUpInside)
        view.addShadow()
        return view
    }()
    lazy var textField: UITextField = {
        let field = UITextField()
        field.addTarget(self, action: #selector(textfieldEditingChanged(_:)), for: .editingChanged)
        field.delegate = self
        field.textColor = UIColor.v2Color.lightBlack
        field.tintColor = UIColor.v2Color.blue
        field.borderStyle = .none
        field.returnKeyType = .search
        field.isUserInteractionEnabled = false
        field.clearButtonMode = .whileEditing
        field.font = UIFont.boldSystemFont(ofSize: 16)
        field.placeholder = "搜索地点"
        return field
    }()
    lazy var searchImageView: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "Main_Search"))
        return imgV
    }()
    lazy var searchCancelBtn: QMUIButton = {
        let cancleButton = QMUIButton()
        cancleButton.setTitle(InternationStr("取消"), for: .normal)
        cancleButton.setTitleColor(UIColor.v2Color.blue, for: .normal)
        cancleButton.titleLabel?.font = Font(14)
        cancleButton.addTarget(self, action: #selector(myResignFirstResponder), for: .touchUpInside)
        cancleButton.alpha = 0
        cancleButton.isHidden = true
        return cancleButton
    }()
    lazy var coverBgView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.myResignFirstResponder()
        }))
        return view
    }()
    lazy var searchTableView: UITableView = {
        let tbv = UITableView(frame: CGRect.zero, style: .plain)
        tbv.delegate = self
        tbv.dataSource = self
        tbv.backgroundColor = UIColor.white
        tbv.layer.borderWidth = 0.5
        tbv.layer.borderColor = UIColor.v2Color.separator.cgColor
        tbv.rowHeight = 54
        tbv.separatorStyle = .none
        tbv.registerNib(SW_MapViewPoiCell.self, forCellReuseIdentifier: "SW_MapViewPoiCellID")
        tbv.alpha = 0
        if #available(iOS 11.0, *) {
            tbv.contentInsetAdjustmentBehavior = .never
        }
        tbv.ly_emptyView = LYEmptyView.empty(withImageStr: nil, titleStr: "抱歉，没有找到相关内容", detailStr: "")
        tbv.ly_emptyView.contentViewY = 100
        tbv.keyboardDismissMode = .onDrag
        tbv.tableFooterView = UIView()
        return tbv
    }()
    lazy var tableView: PlaceAroundTableView = {
        let tbv = PlaceAroundTableView(frame: CGRect.zero)
        tbv.delegate = self
        return tbv
    }()
    /// 中间红点标记
    var centerAnnotationView = UIImageView(image: UIImage(named: "wateRedBlank"))
    /// 当前位置按钮
    lazy var locationBtn: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.autoresizingMask = .flexibleTopMargin
        btn.addTarget(self, action: #selector(actionLocation), for: .touchUpInside)
        btn.setImage(UIImage(named: "gps_normal"), for: .normal)
        btn.setImage(UIImage(named: "gps_highlted"), for: .highlighted)
        btn.setImage(UIImage(named: "gps_selected"), for: .selected)
        btn.isSelected = true
        return btn
    }()
    
    private var isLocated: Bool = false
    private var currentIsTop = true
    private var searchPoiArray: [AMapPOI] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    //MARK: - init初始化
    func setup() {
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(NAV_TOTAL_HEIGHT)
        }
        navBar.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalTo(-11)
        }
        navBar.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.leading.bottom.equalToSuperview()
        }
        navBar.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.trailing.bottom.equalToSuperview()
        }
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(340)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(mapView.snp.bottom)
        }
        mapView.addSubview(centerAnnotationView)
        centerAnnotationView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
        }
        view.addSubview(locationBtn)
        locationBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.trailing.equalTo(mapView.snp.trailing).offset(-10)
            make.bottom.equalTo(mapView.snp.bottom).offset(-25)
        }
        view.addSubview(coverBgView)
        coverBgView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.trailing.leading.bottom.equalToSuperview()
        }
        view.addSubview(searchBgView)
        searchBgView.addSubview(textField)
        textField.setPlaceholderColor(UIColor.v2Color.lightGray)
        searchBgView.addSubview(searchImageView)
        searchBgView.addSubview(searchCancelBtn)
        
        searchBgView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.height.equalTo(35)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBgView.snp.bottom)
            make.bottom.trailing.leading.equalToSuperview()
        }
        textField.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        searchImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(textField.snp.centerY)
            make.trailing.equalTo(textField.snp.leading).offset(-5)
        }
        searchCancelBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(textField.snp.centerY)
            make.width.equalTo(60)
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        view.layoutIfNeeded()
        mapView.showsScale = true
        mapView.scaleOrigin = CGPoint(x: 10, y: mapView.height - 30)
        mapView.showsCompass = false
        mapView.logoCenter = CGPoint(x: mapView.width - 45, y: mapView.height - 15)
    }
    
    //MARK: - Action
    @objc func cancelBtnClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// 发送按钮点击
    ///
    /// - Parameter sender: 发送按钮点击
    @objc func sendBtnClick(_ sender: UIBarButtonItem) {
        /// 有选择发送位置
        if let poi = tableView.selectPoi {
            delegate?.sendLocationLatitude(Double(poi.location!.latitude), longitude: Double(poi.location!.longitude), addressJsonString: ["positionName": poi.name, "positionAddress": poi.province + poi.city + poi.district + poi.address].toJSONString())
            dismiss(animated: true, completion: nil)
        } else {
            showAlertMessage("请选择发送位置", MYWINDOW)
        }
    }
    
    func actionSearchAround(at coordinate: CLLocationCoordinate2D) {
        searchReGeocode(withCoordinate: coordinate)
        searchPoi(withCoordinate: coordinate)
        centerAnnotationAnimimate()
    }
    
    @objc func actionLocation() {
        locationBtn.isSelected = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        actionSearchAround(at: mapView.userLocation.coordinate)
    }
    
    /// 搜索周边
    func searchPoi(withCoordinate coord: CLLocationCoordinate2D, cityCode: String? = nil) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
        request.radius = 3000
        request.offset = 50
        request.sortrule = 0
        if let cityCode = cityCode {
            request.city = cityCode
        }
        request.types = "汽车销售|汽车维修|餐饮服务|购物服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|金融保险服务|公司企业|道路附属设施"
        request.requireExtension = true
        request.page = 1
        self.searchPoi.aMapPOIAroundSearch(request)
    }
    
    @objc func searchPOI(withKeyword keyword: String?) {
        
        if keyword == nil || keyword == "" {
            return
        }
        let request = AMapPOIKeywordsSearchRequest()
        request.offset = 50
        request.keywords = keyword!
        request.requireExtension = true
        if let poi = tableView.selectPoi {
            request.location = poi.location
        }
        request.city = tableView.selectCityCode
        search.aMapPOIKeywordsSearch(request)
    }
    
    
    func searchReGeocode(withCoordinate coord: CLLocationCoordinate2D) {
        let request = AMapReGeocodeSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
        request.requireExtension = true
        self.searchPoi.aMapReGoecodeSearch(request)
    }
    
    func centerAnnotationAnimimate() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            var center = self.centerAnnotationView.center
            center.y -= 20
            self.centerAnnotationView.center = center
        }, completion: { _ in })
        UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseIn, animations: {() -> Void in
            var center = self.centerAnnotationView.center
            center.y += 20
            self.centerAnnotationView.center = center
        }, completion: { _ in })
    }
    
    /// 点击搜索框进入编辑
    @objc private func myBecomeFirstResponder() {
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
        textField.font = Font(16)
        
        navBar.snp.updateConstraints { (update) in
            update.top.equalToSuperview().offset(-NAV_TOTAL_HEIGHT)
        }
        
        searchBgView.snp.remakeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom).offset(0)
            make.height.equalTo(NAV_TOTAL_HEIGHT)
            make.leading.trailing.equalToSuperview()
        }
        
        textField.snp.remakeConstraints { (make) in
            make.leading.equalTo(35)
            make.trailing.equalTo(-60)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        searchCancelBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.searchCancelBtn.alpha = 1
            self.coverBgView.alpha = 1
        }) { (finish) in
        }
    }
    
    @objc private func myResignFirstResponder() {
        textField.resignFirstResponder()
        textField.text = ""
        textField.isUserInteractionEnabled = false
        textField.font = UIFont.boldSystemFont(ofSize: 16)
        
        navBar.snp.updateConstraints { (update) in
            update.top.equalToSuperview().offset(0)
        }
        searchBgView.snp.remakeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom).offset(10)
            make.height.equalTo(35)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
        }
        textField.snp.remakeConstraints { (make) in
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.searchCancelBtn.alpha = 0
            self.coverBgView.alpha = 0
            self.searchTableView.alpha = 0
        }) { (finish) in
            self.searchCancelBtn.isHidden = true
            self.searchPoiArray = []
            self.searchTableView.reloadData()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

//MARK:- PlaceAroundTableViewDeleagate
extension SW_LocationViewController: PlaceAroundTableViewDeleagate {
    /// 点击tableview改变选择的位置
    func didTableViewSelectedChanged(selectedPOI: AMapPOI!) {
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(selectedPOI.location.latitude), longitude: CLLocationDegrees(selectedPOI.location.longitude))
        locationBtn.isSelected = isSameCoordinate(mapView.userLocation.coordinate, right: location)
        mapView.setCenter(location, animated: true)
    }
    
    /// mapview大小改变  滚动时变化
    func didScrollToTop(isTop: Bool) {
        guard currentIsTop != isTop else { return }
        currentIsTop = isTop
        
        mapView.snp.updateConstraints { (update) in
            update.height.equalTo(isTop ? 340 : 200)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction,  animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finish) in
            self.mapView.scaleOrigin = CGPoint(x: 10, y: self.mapView.height - 30)
            self.mapView.logoCenter = CGPoint(x: self.mapView.width - 45, y: self.mapView.height - 15)
        })
    }
}

//MARK: - MAMapViewDelegate
extension SW_LocationViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            /// 移动的时候可以判断一下位置是否是用户的位置
            locationBtn.isSelected = isSameCoordinate(mapView.userLocation.coordinate, right: mapView.centerCoordinate)
            actionSearchAround(at: mapView.centerCoordinate)
        }
    }
    /// 判断两个定位是否相近，误差在0.0001内属于同一个地点
    ///
    /// - Parameters:
    ///   - left: 左边定位
    ///   - right: 右边定位
    /// - Returns: true 同一个定点
    private func isSameCoordinate(_ left: CLLocationCoordinate2D, right: CLLocationCoordinate2D)  -> Bool {
        if abs(left.latitude - right.latitude) <= 0.0001 {
            if abs(left.longitude - right.longitude) <= 0.0001 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !updatingLocation {
            /// 指针头部信息更新，指针方向修改
            return
        }
        if userLocation.location.horizontalAccuracy < 0 || userLocation.location.verticalAccuracy < 0 {
            return
        }
        // only the first locate used. 第一次定位成功后调用
        if !self.isLocated {
            self.isLocated = true
            self.mapView.userTrackingMode = .follow
            self.mapView.zoomLevel = 14.25
            self.mapView.centerCoordinate = userLocation.location.coordinate
            self.actionSearchAround(at: userLocation.location.coordinate)
        }
    }
  
}

//MARK: - tableviewdelegate
extension SW_LocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard searchPoiArray.count > indexPath.row else { return }
        
        myResignFirstResponder()
        
        let poi = searchPoiArray[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location!.latitude), longitude: CLLocationDegrees(poi.location!.longitude))
        locationBtn.isSelected = isSameCoordinate(mapView.userLocation.coordinate, right: coordinate)
        mapView.setCenter(coordinate, animated: true)
        self.tableView.setCurrentPoi(poi)
        searchPoi(withCoordinate: coordinate, cityCode: poi.citycode)
        centerAnnotationAnimimate()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPoiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_MapViewPoiCellID", for: indexPath) as! SW_MapViewPoiCell
        let poi: AMapPOI = searchPoiArray[indexPath.row]
        cell.keyword = textField.text ?? ""
        cell.poi = poi
        cell.isHeader = false
        cell.isSelect = false
        return cell
    }
}


extension SW_LocationViewController: UITextFieldDelegate {
    /// 内容改变 延迟执行搜索
    @objc func textfieldEditingChanged(_ sender: UITextField) {
        searchTableView.alpha = sender.text?.count == 0 ? 0 : 1
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        /// 延迟搜索
        self.perform(#selector(searchPOI(withKeyword:)), with: sender.text, afterDelay: 0.6, inModes: [.default])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        searchPOI(withKeyword: textField.text)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        //设置了限制长度 搜索关键词最多50位 可以改
        let textcount = textField.text?.count ?? 0
        if string.count + textcount - range.length > 50 {
            return false
        }
        return true
    }
}

//MARK: - AMapSearchDelegate
extension SW_LocationViewController: AMapSearchDelegate {
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("error :\(String(describing: error))")
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        self.searchPoiArray.removeAll()
        self.searchPoiArray.append(contentsOf: response.pois)
        
        self.searchTableView.reloadData()
        if self.searchPoiArray.count > 0 {
            self.searchTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

