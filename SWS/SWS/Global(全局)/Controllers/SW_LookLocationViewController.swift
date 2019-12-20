//
//  SW_LookLocationViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/16.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_LookLocationViewController: UIViewController {
    /// 目标位置 必须要有一个
    private var currentLocation: CLLocationCoordinate2D!
    private var positionName = ""
    private var positionAddress = ""
    private let appName = "效率+"
    @IBOutlet weak var mapView: MAMapView!
    
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var positionNameLb: UILabel!
    
    @IBOutlet weak var positionAddressNameLb: UILabel!

    @objc init(_ location: CLLocationCoordinate2D, positionName: String, positionAddress: String) {
        super.init(nibName: "SW_LookLocationViewController", bundle: nil)
        self.currentLocation = location
        self.positionName = positionName
        self.positionAddress = positionAddress
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setup() {
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        
        positionNameLb.text = positionName
        positionAddressNameLb.text = positionAddress
        
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.distanceFilter = 10
        mapView.touchPOIEnabled = false
        mapView.showsUserLocation = true
        let representation = MAUserLocationRepresentation()
        representation.locationDotFillColor = UIColor.v2Color.blue
//        representation.image = #imageLiteral(resourceName: "mine_gps_location")
        mapView.update(representation)
        
        view.layoutIfNeeded()
        mapView.showsScale = true
        mapView.scaleOrigin = CGPoint(x: 10, y: mapView.height - 30)
        mapView.showsCompass = false
        mapView.logoCenter = CGPoint(x: mapView.width - 45, y: mapView.height - 15)
        mapView.userTrackingMode = .followWithHeading
        mapView.zoomLevel = 14.25
        mapView.centerCoordinate = currentLocation
        let anno = MAPointAnnotation()
        anno.coordinate = currentLocation
        mapView.addAnnotation(anno)
        mapView.showAnnotations([anno], animated: true)
    }

    @IBAction func backActionClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locationBtnClick(_ sender: UIButton) {
        locationBtn.isSelected = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func navigationBtnClick(_ sender: UIButton) {
        let alter = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if let popoverController = alter.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let cancle = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (a) in
        }
        
        let action1 = UIAlertAction.init(title: "苹果地图", style: UIAlertAction.Style.default) { (b) in
            self.appleMap()
        }
        alter.addAction(action1)
        
        if UIApplication.shared.canOpenURL(URL(string: "iosamap://")!) {
            let action2 = UIAlertAction.init(title: "高德地图", style: UIAlertAction.Style.default) { (b) in
                self.amap()
            }
            alter.addAction(action2)
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "baidumap://")!) {
            let action2 = UIAlertAction.init(title: "百度地图", style: UIAlertAction.Style.default) { (b) in
                self.baidumap()
            }
            alter.addAction(action2)
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let action2 = UIAlertAction.init(title: "谷歌地图", style: UIAlertAction.Style.default) { (b) in
                self.comgooglemaps()
            }
            alter.addAction(action2)
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "qqmap://")!) {
            let action2 = UIAlertAction.init(title: "腾讯地图", style: UIAlertAction.Style.default) { (b) in
                self.qqmap()
            }
            alter.addAction(action2)
        }
        
        alter.addAction(cancle)
        
        self.present(alter, animated: true, completion: nil)
    }
    
    // 苹果地图
    func appleMap() {
        let formLocation = MKMapItem.forCurrentLocation()
        let toLocation = MKMapItem(placemark:MKPlacemark(coordinate:self.currentLocation,addressDictionary:nil))
        toLocation.name = positionName
        MKMapItem.openMaps(with: [formLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: "true"])
    }
    
    // 高德地图
    private func amap() {
        let urlString = "iosamap://path?sourceApplication=\(appName)&dname=\(positionName)&dlat=\(currentLocation.latitude)&dlon=\(currentLocation.longitude)&t=0" as NSString
        openMap(urlString)
    }
    
    // 百度地图
    private func baidumap() {
        //我的位置代表起点位置为当前位置，也可以输入其他位置作为起点位置，如天安门
//        let desLocation = bd09Encrypt(currentLocation)
        let urlString = "baidumap://map/direction?origin={{我的位置}}&destination=name:\(positionName)|latlng:\(currentLocation.latitude),\(currentLocation.longitude)&mode=driving&src=\(appName)&coord_type=gcj02" as NSString
//        bd09ll
        openMap(urlString)
    }
    
    // 谷歌地图
    private func comgooglemaps() {
        let urlString = "comgooglemaps://?x-source=\(appName)&x-success=efficiencyOA&saddr=&daddr=\(currentLocation.latitude),\(currentLocation.longitude)&directionsmode=driving" as NSString
        openMap(urlString)
    }
    
    // 腾讯地图
    private func qqmap() {
        let urlString = "qqmap://map/routeplan?type=drive&from=我的位置&to=\(positionName)&tocoord=\(currentLocation.latitude),\(currentLocation.longitude)&policy=1&referer=\(appName)" as NSString
        openMap(urlString)
    }
    
    // 打开第三方地图
    @discardableResult private func openMap(_ urlString: NSString) -> Bool {
        let url = NSURL(string:urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        if UIApplication.shared.canOpenURL(url! as URL) == true {
            UIApplication.shared.openURL(url! as URL)
            return true
        } else {
            return false
        }
    }
    
}

//MARK: - MAMapViewDelegate
extension SW_LookLocationViewController: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            /// 移动的时候可以判断一下位置是否是用户的位置
            locationBtn.isSelected = false
        }
    }
    
//    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
//        if !updatingLocation {
//            /// 指针头部信息更新，指针方向修改
//            return
//        }
//        if userLocation.location.horizontalAccuracy < 0 || userLocation.location.verticalAccuracy < 0 {
//            return
//        }
//    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation as? MAUserLocation) != nil {
            return nil
        }
        
        let reuseId = "annotationViewId"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        annotationView?.image = UIImage(named: "wateRedBlank")
        annotationView?.isEnabled = false
        return annotationView!
    }
   
    /// 转换为百度坐标系
    private func bd09Encrypt(_ gcj02Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x = gcj02Point.longitude
        let y = gcj02Point.latitude
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * .pi)
        let theta = atan2(y, x) + 0.000003 * cos(x * .pi)
        let resultPoint = CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065)
        return resultPoint
    }
}
