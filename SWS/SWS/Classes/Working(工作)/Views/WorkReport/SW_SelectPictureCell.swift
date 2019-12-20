//
//  SW_SelectPictureCell.swift
//  SWS
//
//  Created by jayway on 2018/7/9.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_SelectPictureCell: Cell<String>, CellType {
    
    @IBOutlet weak var pictureLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var rowForCell: SW_SelectPictureRow? {
        return row as? SW_SelectPictureRow
    }
    
    /// 布局代理
    var layoutDelegate = SW_SelectPictureCellDelegate()
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self.layoutDelegate
        layout.lineSpacing = 10
        layout.interitemSpacing = 10
        layout.edgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        collectionView.registerNib(SW_SelectPictureCollectionViewCell.self, forCellReuseIdentifier: "SW_SelectPictureCollectionViewCellID")
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.delegate = self.layoutDelegate
        collectionView.dataSource = self.layoutDelegate
        collectionView.collectionViewLayout = flowLayout
        
        layoutDelegate.rowForCell = rowForCell
        layoutDelegate.collectionView = collectionView
        collectionView.reloadData()
        guard let rowForCell = rowForCell else { return }
        pictureLb.text = "已选择(\(rowForCell.images.count + rowForCell.upImages.count)/\(rowForCell.maxCount))"
    }
    
    public override func update() {
        super.update()
        layoutDelegate.rowForCell = rowForCell
        layoutDelegate.collectionView = collectionView
        collectionView.reloadData()
        guard let rowForCell = rowForCell else { return }
        pictureLb.text = "已选择(\(rowForCell.images.count + rowForCell.upImages.count)/\(rowForCell.maxCount))"
    }
}


class SW_SelectPictureCellDelegate: NSObject {
    
    var rowForCell: SW_SelectPictureRow!
    
    weak var collectionView: UICollectionView?
}

extension SW_SelectPictureCellDelegate: FixedSpacingCollectionLayoutDelegate {
    
    @objc func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREEN_WIDTH - 70)/rowForCell.column, height: (SCREEN_WIDTH - 70)/rowForCell.column)
    }
    
    @objc func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
    
}

extension SW_SelectPictureCellDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(rowForCell.images.count + rowForCell.upImages.count + 1, rowForCell.maxCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_SelectPictureCollectionViewCellID", for: indexPath) as! SW_SelectPictureCollectionViewCell
        cell.iconImageView.sd_cancelCurrentImageLoad()
        if indexPath.row == rowForCell.images.count + rowForCell.upImages.count {//添加按钮
            cell.iconImageView.isHidden = true
            cell.addImageBtn.isHidden = false
            cell.canShouDown = false
            cell.coverView.isHidden = true
            cell.showOrHideProgressView(true)
            cell.shouDownBlock = nil
        } else {
            /// upimages
            if indexPath.row > rowForCell.images.count - 1 {
                if rowForCell.upImages.count > indexPath.row-rowForCell.images.count {
                    cell.iconImageView.image = rowForCell.upImages[indexPath.row-rowForCell.images.count]
                } else {
                    ///显示这个图片的时候说明有问题了
                    cell.iconImageView.image = #imageLiteral(resourceName: "work_upload_pictures")
                }
                
                /// 显示进度条跟遮罩  用图片取进度值，没取得则为0  取得则使用
                cell.coverView.isHidden = false
                cell.showOrHideProgressView(false)
                cell.setProgress(0, animated: false)
                cell.canShouDown = false
            } else {/// images
                /// 取得有图片，直接使用
                if let image = rowForCell.successImage[rowForCell.images[indexPath.row]] {
                    cell.iconImageView.image = image
                } else if let url = URL(string: rowForCell.images[indexPath.row]) {
                    cell.iconImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "work_upload_pictures"))
                } else {
                    cell.iconImageView.image = #imageLiteral(resourceName: "work_upload_pictures")
                }
                
                /// 隐藏进度条跟遮罩
                cell.coverView.isHidden = true
                cell.showOrHideProgressView(true)
                
                cell.canShouDown = true
            }
            
            cell.iconImageView.isHidden = false
            cell.addImageBtn.isHidden = true
            cell.shouDownBlock = { [weak self] in//点击删除某个成员
                self?.rowForCell.didShouDownRow?(indexPath)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == rowForCell.images.count + rowForCell.upImages.count {//添加按钮
            rowForCell.didSelectAdd?()
        } else {
            //选中图片，查看大图
            if let cell = collectionView.cellForItem(at: indexPath) as? SW_SelectPictureCollectionViewCell {
                let vc = SW_ImagePreviewViewController([cell.iconImageView.image ?? #imageLiteral(resourceName: "work_upload_pictures")])
                vc.sourceImageView = {
                    return cell.iconImageView
                }
                getTopVC().present(vc, animated: true, completion: nil)
//                vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                    aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: cell.iconImageView.convert(cell.iconImageView.frame, to: nil))
//                }
//                vc.startPreviewFromRect(inScreenCoordinate: cell.iconImageView.convert(cell.iconImageView.frame, to: nil))
            }
        }
    }
}

// 自定义的Row，拥有SW_HobbyCell和对应的value
final class SW_SelectPictureRow: Row<SW_SelectPictureCell>, RowType {
    /// 已经上传完成的图片数组
    var images = [String]()
    /// 选择回来正在上传的图片数组
    var upImages = [UIImage]()
    /// 用url对应image，选择图片并上传完成后存在这个数组中，取得直接用image
    var successImage = [String: UIImage]()
    
    /// 最大的选择人数
    var maxCount = 8
    
    /// 一行显示的列数
    var column: CGFloat = 5
    
    /// 删除某个成员
    var didShouDownRow: CollectionViewDidSelectBlock?
    
    var didSelectAdd: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_GroupMemberCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_SelectPictureCell>(nibName: "SW_SelectPictureCell")
    }
    
    func updateUpImagesProgress(image: UIImage, progress: Float) {
        if let index = upImages.firstIndex(of: image) {/// 找到index
            if let imageCell =  cell.collectionView.cellForItem(at: IndexPath(row: index+images.count, section: 0)) as? SW_SelectPictureCollectionViewCell, imageCell.iconImageView.image == image {
                imageCell.setProgress(progress, animated: true)
            }
        }
        
    }
}
