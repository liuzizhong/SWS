//
//  SW_GroupMemberCell.swift
//  SWS
//
//  Created by jayway on 2018/5/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//


import Eureka

typealias CollectionViewDidSelectBlock = (IndexPath)->Void

class SW_GroupMemberCell: Cell<String>, CellType {
    
    @IBOutlet weak var peopleLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextImage: UIImageView!
    
    var membersCount = 0
    
    var members = [SW_RangeModel]()
    
    var isOwner = false
    
    var layoutDelegate = SW_GroupMemberCellDelegate()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self.layoutDelegate
        layout.lineSpacing = (SCREEN_WIDTH - 300) / 4
        layout.interitemSpacing = 15
        layout.edgeInset = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    var didSelectRow: CollectionViewDidSelectBlock?
    
    public override func setup() {
        super.setup()
        
        collectionView.registerNib(SW_GroupMemberCollectionViewCell.self, forCellReuseIdentifier: "SW_GroupMemberCollectionViewCellID")
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self.layoutDelegate
        collectionView.dataSource = self.layoutDelegate
        collectionView.collectionViewLayout = flowLayout
        
//        titleLb.text = rowForCell?.rowTitle
//        if let tags = row.value {
        layoutDelegate.isOwner = isOwner
        layoutDelegate.collectionView = collectionView
        layoutDelegate.members = members
        layoutDelegate.didSelectRow = didSelectRow
        peopleLb.text = "\(membersCount)/500"
//        }
    }
    
    public override func update() {
        super.update()
//        guard let value = row.value else { return }
        layoutDelegate.isOwner = isOwner
//        layoutDelegate.collectionView = collectionView
        layoutDelegate.members = members
        layoutDelegate.didSelectRow = didSelectRow
        peopleLb.text = "\(membersCount)/500"
    }
}



class SW_GroupMemberCellDelegate: NSObject {

    var members = [SW_RangeModel]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    var didSelectRow: CollectionViewDidSelectBlock?
    
    var isOwner = false

    weak var collectionView: UICollectionView?
}

extension SW_GroupMemberCellDelegate: FixedSpacingCollectionLayoutDelegate {
    
    @objc func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 54, height: 76)
    }
    
    @objc func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
    
}

extension SW_GroupMemberCellDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isOwner ? members.count + 2 : members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_GroupMemberCollectionViewCellID", for: indexPath) as! SW_GroupMemberCollectionViewCell
        cell.nameLabel.textColor = UIColor.v2Color.lightBlack
        if isOwner {
            if indexPath.row > 1 {
                cell.model = members[indexPath.row - 2]
            } else {
                cell.iconImageView.image = indexPath.row == 0 ? #imageLiteral(resourceName: "group_add") : #imageLiteral(resourceName: "group_delete")
                cell.nameLabel.text = ""//indexPath.row == 0 ? "邀 请" : "踢 出"
                cell.nameLabel.textColor = UIColor.v2Color.blue
            }
        } else {
            cell.model = members[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectRow?(indexPath)
    }
}

// 自定义的Row，拥有SW_HobbyCell和对应的value
final class SW_GroupMemberRow: Row<SW_GroupMemberCell>, RowType {
    
    var rowTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_GroupMemberCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_GroupMemberCell>(nibName: "SW_GroupMemberCell")
    }
}


