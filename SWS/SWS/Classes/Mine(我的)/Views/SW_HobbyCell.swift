//
//  SW_HobbyCell.swift
//  SWS
//
//  Created by jayway on 2018/4/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_HobbyCell: Cell<String>, CellType {

    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextImage: UIImageView!
    
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private var rowForCell : SW_HobbyRow? {
        return row as? SW_HobbyRow
    }
    
    var layoutDelegate = HobbyCellDelegate()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self.layoutDelegate
        layout.lineSpacing = 8
        layout.interitemSpacing = 8
        layout.edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)
        return layout
    }()
    
    public override func setup() {
        super.setup()
        collectionView.register(SW_HobbyTagCell.self, forCellWithReuseIdentifier: "SW_HobbyTagCellID")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self.layoutDelegate
        collectionView.dataSource = self.layoutDelegate
        collectionView.collectionViewLayout = flowLayout
        collectionView.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            self?.rowForCell?.tapBlock?()
        })
        titleLb.text = rowForCell?.rowTitle
        if let tags = row.value {
            layoutDelegate.collectionView = collectionView
            layoutDelegate.allTag = tags.zzComponents(separatedBy: "_")
        }
        
        bottomLine.isHidden = !(rowForCell?.isShowBottomLine ?? false)
    }
    
    public override func update() {
        super.update()
        guard let value = row.value else { return }
        layoutDelegate.collectionView = collectionView
        layoutDelegate.allTag = value.zzComponents(separatedBy: "_")
    }
}

//Fixed spacing collection view layout
extension HobbyCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_HobbyTagCellID", for: indexPath) as! SW_HobbyTagCell
        cell.nameLb.text = allTag[indexPath.row]
        return cell
    }
}

extension HobbyCellDelegate: FixedSpacingCollectionLayoutDelegate {
    
    @objc func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        guard  allTag.count > indexPath.row else { return CGSize.zero }
        let string = allTag[indexPath.row]
        let maxW = SCREEN_WIDTH - 30
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(14)])
        return CGSize(width: min(textSize.width + 11 * 2.0, maxW), height: 28)
    }
    
    @objc func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
//        collectionViewHeight.constant = size.height
    }
    
}

class HobbyCellDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var allTag = [String]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    weak var collectionView: UICollectionView?
}


// 自定义的Row，拥有SW_HobbyCell和对应的value
final class SW_HobbyRow: Row<SW_HobbyCell>, RowType {
    
    var rowTitle = ""
    
    var isShowBottomLine = false
    
    var tapBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_HobbyCell>(nibName: "SW_HobbyCell")
    }
}

class SW_HobbyTagCell: UICollectionViewCell {
    
    lazy var nameLb: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.white
        lb.font = Font(14)
        return lb
    }()

   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(nameLb)
        nameLb.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        backgroundColor = UIColor.v2Color.blue
        layer.cornerRadius = 2
        layer.masksToBounds = true
    }
    
}

