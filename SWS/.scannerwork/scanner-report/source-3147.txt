//
//  SW_SelectTagViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum tagType {
    case specialty
    case hobby
    
    var rawTitle: String {
        switch self {
        case .specialty:
            return "特长"
        case .hobby:
            return "爱好"
        }
    }
}

class SW_SelectTagViewController: UIViewController {

    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var tipLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        
        layout.delegate = self
        layout.lineSpacing = 12
        layout.interitemSpacing = 13
        layout.edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    var type = tagType.specialty
    
    var selectTag = [String]() {
        didSet {
            
        }
    }
    var allTag = [String]()
    
    var sureBlock: ((String)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = flowLayout
        
//        collectionView.register(UINib(nibName: String(describing: LabelCollectionViewCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: reuseID)
        
        titleLb.text = InternationStr("添加\(type.rawTitle)标签")
        changeTipLb()
        
        requestGetAllTag()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    fileprivate func requestGetAllTag() {
        var request : SWSLoginRequest!
        switch type {
        case .hobby:
            request = SWSLoginService.hobbyLabelList()
        case .specialty:
            request = SWSLoginService.specialtiesLabelList()
        }
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                PrintLog("获取tag成功")
                let tags =  json.arrayValue.map({ (jsonDict) -> String in
                    if let dict = jsonDict.dictionaryValue["name"] {
                        return dict.stringValue
                    }
                    return ""
                })
                //过滤无用的选项
                self.allTag = tags.filter({ return !$0.isEmpty })
                
                self.collectionView.reloadData()
                
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
        
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnAction(_ sender: UIButton) {
        sureBlock?(selectTag.joined(separator: "_"))
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func changeTipLb() {
        if selectTag.count == 0 {
            tipLb.text = InternationStr("添加您的8个\(type.rawTitle)标签")
        } else if selectTag.count == 8 {
            tipLb.text = InternationStr("已经添加8个\(type.rawTitle)标签")
        } else {
            tipLb.text = InternationStr("已添加\(selectTag.count)个标签，还可添加\(8-selectTag.count)个标签")
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

//Fixed spacing collection view layout
extension SW_SelectTagViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCellID", for: indexPath) as!SW_TagCollectionViewCell
        let tag = InternationStr(allTag[indexPath.row])
        
        cell.nameLb.text = tag
        cell.isSelect = selectTag.contains(tag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = InternationStr(allTag[indexPath.row])
        if let index = selectTag.index(of: tag) {
            selectTag.remove(at: index)
            changeTipLb()
            collectionView.reloadData()
//            collectionView.reloadItems(at: [indexPath])
        } else {
            if selectTag.count >= 8 {
                showAlertMessage("最多添加8个\(type.rawTitle)标签", self.view)
            } else {
                selectTag.append(tag)
                changeTipLb()
//                collectionView.reloadItems(at: [indexPath])
                collectionView.reloadData()
            }
        }
        
    }

}


extension SW_SelectTagViewController: FixedSpacingCollectionLayoutDelegate {
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        guard  allTag.count > indexPath.row else { return CGSize.zero }
        let string = allTag[indexPath.row]
        let maxW = collectionView.bounds.size.width - 30
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(14)])
        return CGSize(width: min(textSize.width + 18 * 2.0, maxW), height: 33)
       
    }
    
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
}
