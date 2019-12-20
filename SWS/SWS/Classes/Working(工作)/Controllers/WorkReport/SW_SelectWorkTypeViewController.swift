//
//  SW_SelectWorkTypeViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectWorkTypeViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isCanBack = true
    
    private lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 12
        layout.interitemSpacing = 13
        layout.edgeInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        return layout
    }()
    
    private lazy var emptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "work_report_worktag", titleStr: "您还没有添加任务标签", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.mainColor.lightGray
        emptyView?.contentViewOffset = -50
        return emptyView!
    }()
    
    var selectWork = [NormalModel]()
    
    var allWork = [NormalModel]()
    
    var dismissBlock: (([NormalModel])->Void)?
    
    var sureBlock: (([NormalModel])->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - setup
    private func setup() {
       backBtn.isHidden = !isCanBack
        collectionView.collectionViewLayout = flowLayout
        collectionView.ly_emptyView = emptyView
//
        requestGetAllWork()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    private func requestGetAllWork() {
        SW_WorkingService.getWorkType().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                PrintLog("获取tag成功")
                //过滤无用的选项
                self.allWork = json["list"].arrayValue.map({ return NormalModel($0) })

                self.collectionView.reloadData()

            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
        
    }
    
    //MARK: - btn action
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sureBtnClick(_ sender: UIButton) {
        if selectWork.count == 0 {
            showAlertMessage("请选择任务标签", MYWINDOW)
            return
        }
        if let dismissBlock = dismissBlock {
            dismissBlock(selectWork)
            return
        }
        sureBlock?(selectWork)
        dismiss(animated: true, completion: nil)
    }
    
}


//Fixed spacing collection view layout
extension SW_SelectWorkTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allWork.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCellID", for: indexPath) as! SW_TagCollectionViewCell
        let tag = InternationStr(allWork[indexPath.row].name)
        
        cell.nameLb.text = tag
        cell.isSelect = selectWork.contains(where: { return $0.name == tag })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let work = allWork[indexPath.row]
        
        if let index = selectWork.index(where: { return $0.name == work.name }) {
            selectWork.remove(at: index)
        } else {
            selectWork.append(work)
        }
        collectionView.reloadData()
        
    }
    
}


extension SW_SelectWorkTypeViewController: FixedSpacingCollectionLayoutDelegate {
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        guard  allWork.count > indexPath.row else { return CGSize.zero }
        let string = allWork[indexPath.row].name
        let maxW = collectionView.bounds.size.width - 30
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(14)])
        return CGSize(width: min(textSize.width + 18 * 2.0, maxW), height: 39)
        
    }
    
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
}





