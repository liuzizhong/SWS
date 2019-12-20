//
//  SW_ChatSettingGroupIconCell.swift
//  SWS
//
//  Created by jayway on 2018/12/1.
//  Copyright © 2018 yuanrui. All rights reserved.
//


import Eureka

class SW_ChatSettingGroupIconCell: Cell<String>, CellType {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var cemeraImgView: UIImageView!
    
    private var rowForCell : SW_ChatSettingGroupIconRow? {
        return row as? SW_ChatSettingGroupIconRow
    }
    
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
        guard let rowForCell = rowForCell else { return }
        iconImageView.layer.cornerRadius = iconImageView.height/2
        
        cemeraImgView.isHidden = !rowForCell.isGroupOwner
        
        if let url = URL(string: row.value ?? "") {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_groupavatar"))
        } else {
            iconImageView.image = UIImage(named: "icon_groupavatar")
        }
        
        iconImageView.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            guard let self = self else { return }

            let vc = SW_ImagePreviewViewController([self.iconImageView.image!])
            vc.sourceImageView = {
                return self.iconImageView
            }
            self.getTopVC().present(vc, animated: true, completion: nil)
//            vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: self.convert(self.iconImageView.frame, to: nil))
//            }
//            vc.startPreviewFromRect(inScreenCoordinate: self.convert(self.iconImageView.frame, to: nil), cornerRadius: self.iconImageView.layer.cornerRadius)
        })
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_ChatSettingGroupIconRow: Row<SW_ChatSettingGroupIconCell>, RowType {
    
    var editActionBlock: NormalBlock?
    
    var isGroupOwner = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_ChatSettingGroupIconCell>(nibName: "SW_ChatSettingGroupIconCell")
    }
}
