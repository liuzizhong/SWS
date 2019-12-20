//
//  SW_SearchChatPicViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchChatPicViewController: UIViewController {
    
    private var conversation: EMConversation!
    
    private let imageW = (SCREEN_WIDTH - 78) / 5
    
    private var allImages = [picGroupModel]()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: imageW, height: imageW)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        flowLayout.scrollDirection = .vertical
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        colView.delegate = self
        colView.dataSource = self
        colView.alwaysBounceVertical = true
        colView.showsHorizontalScrollIndicator = false
        colView.showsVerticalScrollIndicator = true
        colView.register(GuideCell.self, forCellWithReuseIdentifier: "guideCellID")
        colView.register(UINib(nibName: String(describing: SW_NormalCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderReuseId")
//
        return colView
    }()
    
   
    init(_ conversation: EMConversation) {
        super.init(nibName: nil, bundle: nil)
        self.conversation = conversation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        searchPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //setup
    private func setup() {
        navigationItem.title = InternationStr("图片")
        
        view.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
       
    }
    
    /// 搜索数据库聊天图片
    private func searchPicture() {
        conversation.loadMessages(with: EMMessageBodyTypeImage, timestamp: -1, count: 9999, fromUser: nil, searchDirection: EMMessageSearchDirectionUp) { (messages, error) in
            ///数据处理 -若时间长 可异步处理
            if let messages = messages as? [EMMessage] {
                messages.forEach({ (message) in
                    ///获取到图片的时间 key  判断key是否存在
                    let timeKey = Date.dateWith(timeInterval: TimeInterval(message.timestamp)).simpleTimeString(formatter: .yearMonth)
                    
                    if let index = self.allImages.firstIndex(where: { return $0.timeString == timeKey }) {///找到对应的组
                        self.allImages[index].messages.insert(message, at: 0)
//                        append(message)
                    } else {///没有对应的组  新创建一个
                        let model = picGroupModel(timeKey)
                        model.messages.append(message)
                        self.allImages.insert(model, at: 0)
//                        append(model)
                    }
                })
            }
            
            self.collectionView.reloadData()
        }
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension SW_SearchChatPicViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages[section].messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guideCellID", for: indexPath) as? GuideCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = UIColor.white
        cell.imageView.layer.borderWidth = 0.5
        cell.imageView.layer.borderColor = UIColor.v2Color.separator.cgColor
        let message = allImages[indexPath.section].messages[indexPath.row]
        let imageBody = message.body as! EMImageMessageBody
        //缩略图下载完成的时候直接用
        if imageBody.thumbnailDownloadStatus == EMDownloadStatusSucceed {
            if imageBody.downloadStatus == EMDownloadStatusSucceed {
                if imageBody.localPath.count > 0 {
                    cell.imageView.image = UIImage(contentsOfFile: imageBody.localPath)
                    return cell
                }
            }
            EMClient.shared().chatManager.downloadMessageAttachment(message, progress: nil) { (msg, error) in
                if error == nil {
                    if imageBody.localPath.count > 0 {
                        cell.imageView.image = UIImage(contentsOfFile: imageBody.localPath)
                    }
                }
            }
        } else {//还没下载则重新下载后再刷新该row
            EMClient.shared().chatManager.downloadMessageThumbnail(message, progress: nil) { (msg, error) in
                if error == nil {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        //定制头部视图的内容
        let headerV = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderReuseId", for: indexPath) as! SW_NormalCollectionReusableView
        headerV.titleLabel.text = allImages[indexPath.section].timeString
        return headerV
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        ///获取到对应的图片，大图显示
        if let cell = collectionView.cellForItem(at: indexPath) as? GuideCell {
            if let image = cell.imageView.image {//点击头像查看大图
                let vc = SW_ImagePreviewViewController([image])
                vc.sourceImageView = {
                    return cell.imageView
                }
                self.getTopVC().present(vc, animated: true, completion: nil)
//                vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                    aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: cell.convert(cell.imageView.frame, to: nil))
//                }
//                vc.startPreviewFromRect(inScreenCoordinate: cell.convert(cell.imageView.frame, to: nil))
            }
        }
        
    }
    
}

class picGroupModel: NSObject {
    
    var timeString = ""
    
    var messages = [EMMessage]()
    
    init(_ time: String) {
        super.init()
        self.timeString = time
    }
    
}

class GuideCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView(frame: CGRect.zero)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
