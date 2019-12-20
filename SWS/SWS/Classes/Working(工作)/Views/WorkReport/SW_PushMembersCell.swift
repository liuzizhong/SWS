//
//  SW_PushMembersCell.swift
//  SWS
//
//  Created by jayway on 2018/7/9.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_PushMembersCell: Cell<String>, CellType {
    
    @IBOutlet weak var peopleLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// 选择的成员
    var members = [SW_RangeModel]()
    // 最大的选择人数
    var maxCount = 8
    /// 布局代理
    var layoutDelegate = SW_PushMembersCellDelegate()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self.layoutDelegate
        layout.lineSpacing = (SCREEN_WIDTH - 300) / 4
        layout.interitemSpacing = 15
        layout.edgeInset = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    var didSelectRow: CollectionViewDidSelectBlock?
    
    /// 删除某个成员
    var didShouDownRow: CollectionViewDidSelectBlock?
    
    var didSelectAdd: NormalBlock?
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        collectionView.registerNib(SW_GroupMemberCollectionViewCell.self, forCellReuseIdentifier: "SW_GroupMemberCollectionViewCellID")
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self.layoutDelegate
        collectionView.dataSource = self.layoutDelegate
        collectionView.collectionViewLayout = flowLayout

        layoutDelegate.maxCount = maxCount
        layoutDelegate.collectionView = collectionView
        layoutDelegate.members = members
        layoutDelegate.didSelectAdd = didSelectAdd
        layoutDelegate.didShouDownRow = didShouDownRow
        layoutDelegate.didSelectRow = didSelectRow
        peopleLb.text = "已选择(\(members.count)/\(maxCount))"
    }
    
    public override func update() {
        super.update()
        //        guard let value = row.value else { return }
        layoutDelegate.maxCount = maxCount
        layoutDelegate.collectionView = collectionView
        layoutDelegate.members = members
        layoutDelegate.didSelectAdd = didSelectAdd
        layoutDelegate.didShouDownRow = didShouDownRow
        layoutDelegate.didSelectRow = didSelectRow
        peopleLb.text = "已选择(\(members.count)/\(maxCount))"
    }
}



class SW_PushMembersCellDelegate: NSObject {
    
    var members = [SW_RangeModel]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var didSelectRow: CollectionViewDidSelectBlock?
    
    var didShouDownRow: CollectionViewDidSelectBlock?
    
    var didSelectAdd: NormalBlock?
    // 最大的选择人数
    var maxCount = 8
    
    weak var collectionView: UICollectionView?
}

extension SW_PushMembersCellDelegate: FixedSpacingCollectionLayoutDelegate {
    
    @objc func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 54, height: 76)
    }
    
    @objc func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
    
}

extension SW_PushMembersCellDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(members.count + 1, maxCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_GroupMemberCollectionViewCellID", for: indexPath) as! SW_GroupMemberCollectionViewCell
        cell.nameLabel.textColor = #colorLiteral(red: 0.4431372549, green: 0.4431372549, blue: 0.4431372549, alpha: 1)
        if indexPath.row == members.count {//添加按钮
            cell.iconImageView.image = #imageLiteral(resourceName: "group_add")
            cell.nameLabel.text = "添加"
            cell.nameLabel.textColor = UIColor.v2Color.blue
            cell.canShouDown = false
            cell.shouDownBlock = nil
        } else {
            cell.model = members[indexPath.row]
            cell.canShouDown = true
            cell.shouDownBlock = { [weak self] in//点击删除某个成员
                self?.didShouDownRow?(indexPath)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == members.count {//添加按钮
            didSelectAdd?()
        } else {
            didSelectRow?(indexPath)
        }
    }
}

// 自定义的Row，拥有SW_HobbyCell和对应的value
final class SW_PushMembersRow: Row<SW_PushMembersCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_GroupMemberCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_PushMembersCell>(nibName: "SW_PushMembersCell")
    }
}
