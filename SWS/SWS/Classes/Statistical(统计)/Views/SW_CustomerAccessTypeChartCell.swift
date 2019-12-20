//
//  SW_CustomerAccessTypeChartCell.swift
//  SWS
//
//  Created by jayway on 2018/9/11.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 卡片数据类型
///
/// - reception: 接访客户
/// - saleAccess: 销售接待
/// - testDrive: 试乘试驾
/// - telephone: 电话访问
/// - visit: 上门访问
/// - autoShow: 车展访问
enum AccessTypeChartType {
    case reception
    case saleAccess
    case testDrive
    case telephone
    case visit
    case autoShow
    
    var rawTitle: String {
        switch self {
        case .reception:
            return "接访客户"
        case .saleAccess:
            return "销售接待"
        case .testDrive:
            return "试乘试驾"
        case .telephone:
            return "电话访问"
        case .visit:
            return "上门访问"
        case .autoShow:
            return "车展访问"
            
        }
    }
}

let AccessTypeCardNormalHeight = 280

class SW_CustomerAccessTypeChartCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var layout: CardCollectionLayout = {
        let lyout = CardCollectionLayout()
        lyout.itemSize = CGSize(width: SCREEN_WIDTH - 40, height: 200)
        return lyout
    }()
    
    var cardList: [AccessTypeChartType] = [.reception,.saleAccess,.testDrive,.telephone,.visit,.autoShow]
    
    var chartModel: SW_CustomerAccessTypeChartModel? {
        didSet {
            guard let chartModel = chartModel  else { return }
            if chartModel != oldValue {
                if chartModel.accessTypeDatas.count > 0 {
                    collectionViewHeightConstraint.constant = CGFloat((chartModel.accessTypeDatas.count + 1) * 38 + AccessTypeCardNormalHeight)
                    layout.itemSize = CGSize(width: SCREEN_WIDTH - 40, height: CGFloat((chartModel.accessTypeDatas.count + 1) * 38 + AccessTypeCardNormalHeight))
                } else {
                    collectionViewHeightConstraint.constant = CGFloat(AccessTypeCardNormalHeight)
                    layout.itemSize = CGSize(width: SCREEN_WIDTH - 40, height: CGFloat(AccessTypeCardNormalHeight))
                }
                collectionView.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        collectionView.collectionViewLayout = layout
        collectionView.registerNib(SW_CustomerAccessTypeCardCell.self, forCellReuseIdentifier: "SW_CustomerAccessTypeCardCellID")
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SW_CustomerAccessTypeChartCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cardList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_CustomerAccessTypeCardCellID", for: indexPath) as! SW_CustomerAccessTypeCardCell
        cell.cardType = cardList[indexPath.section]
        cell.chartModel = chartModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
extension SW_CustomerAccessTypeChartCell:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 10)
        case cardList.count - 1:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
}
