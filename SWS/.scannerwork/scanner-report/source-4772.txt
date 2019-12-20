//
//  PlaceAroundTableView.swift
//  AMapPlaceChooseDemo
//
//  Created by hanxiaoming on 17/1/10.
//  Copyright © 2017年 FENGSHENG. All rights reserved.
//

import UIKit

@objc protocol PlaceAroundTableViewDeleagate: NSObjectProtocol {
    /// 点击tableview选择位置
    func didTableViewSelectedChanged(selectedPOI: AMapPOI!)
    /// 是否已经滚动到最上面
    func didScrollToTop(isTop: Bool)
}

class PlaceAroundTableView: UIView, UITableViewDataSource, UITableViewDelegate, AMapSearchDelegate {
    
    lazy var tableView: UITableView = {
        let tbv = UITableView(frame: self.bounds, style: UITableView.Style.plain)
        tbv.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        if #available(iOS 11.0, *) {
            tbv.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tbv.registerNib(SW_MapViewPoiCell.self, forCellReuseIdentifier: "SW_MapViewPoiCellID")
        tbv.rowHeight = 54
        tbv.separatorStyle = .none
//        tbv.separatorColor = UIColor.v2Color.separator
//        tbv.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        tbv.delegate = self
        tbv.dataSource = self
        tbv.keyboardDismissMode = .onDrag
        tbv.tableFooterView = UIView()
        return tbv
    }()
    
    weak var delegate: PlaceAroundTableViewDeleagate?
    /// 当前中心点的poi
    var currentPoi: AMapPOI?
    var currentCityCode = ""
    /// 选择的POI
    var selectPoi: AMapPOI?
    var selectCityCode = ""
    var searchPoiArray: [AMapPOI] = []
    var selectedIndexPath = IndexPath(item: 0, section: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setCurrentPoi(_ poi: AMapPOI) {
        currentPoi = poi
        selectPoi = poi
        currentCityCode = poi.citycode
        selectCityCode = poi.citycode
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.none)
    }
    
    //MARK:- AMapSearchDelegate
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("error :\(String(describing: error))")
    }
    
    /* POI 搜索回调. */
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        self.searchPoiArray.removeAll()
        self.searchPoiArray.append(contentsOf: response.pois)
        self.selectedIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
//            for poi in response.regeocode.pois {
//                PrintLog("\(String(describing: poi.name))---\(String(describing: poi.address))---\(String(describing: poi.direction))---\(String(describing: poi.type))---\(String(describing: poi.typecode))")
//            }
//            PrintLog("\(response.regeocode.formattedAddress)---\(response.regeocode.addressComponent.province)---\(response.regeocode.addressComponent.city)---\(response.regeocode.addressComponent.district)---\(response.regeocode.addressComponent.township)---\(response.regeocode.addressComponent.neighborhood)---\(response.regeocode.addressComponent.building)---\(response.regeocode.addressComponent.streetNumber)")
            currentPoi = response.regeocode.pois.first
            selectPoi = currentPoi
            currentCityCode = response.regeocode.addressComponent.citycode
            selectCityCode = response.regeocode.addressComponent.citycode
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    
    //MARK:- TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.tableView.reloadData()
        
        if self.delegate == nil {
            return
        }
        if indexPath.section == 0 {
            selectPoi = currentPoi
            selectCityCode = currentCityCode
            if self.delegate!.responds(to: #selector(PlaceAroundTableViewDeleagate.didTableViewSelectedChanged(selectedPOI:))) {
                if let selectPoi = selectPoi {
                    self.delegate!.didTableViewSelectedChanged(selectedPOI: selectPoi)
                }
            }
        } else {
            if self.delegate!.responds(to: #selector(PlaceAroundTableViewDeleagate.didTableViewSelectedChanged(selectedPOI:))) {
                selectPoi = searchPoiArray[indexPath.row]
                if let selectPoi = selectPoi {
                    selectCityCode = selectPoi.citycode
                    self.delegate!.didTableViewSelectedChanged(selectedPOI: selectPoi)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : searchPoiArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //MARK:- TableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_MapViewPoiCellID", for: indexPath) as! SW_MapViewPoiCell
        cell.keyword = ""
        if indexPath.section == 0 {
            cell.poi = self.currentPoi
            cell.isHeader = true
        } else {
            let poi: AMapPOI = self.searchPoiArray[indexPath.row]
            
//            PrintLog("\(String(describing: poi.province))---\(String(describing: poi.city))---\(poi.district)---\(poi.businessArea)---\(poi.name)---\(poi.address)---\(poi.direction)---\(poi.type)---\(poi.typecode)")
            cell.poi = poi
            cell.isHeader = false
        }
        cell.isSelect = (selectPoi != nil && indexPath == selectedIndexPath)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -15 {
            delegate?.didScrollToTop(isTop: true)
        } else if scrollView.contentOffset.y > 2 {
            delegate?.didScrollToTop(isTop: false)
        }
    }
}
