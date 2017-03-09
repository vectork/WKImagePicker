//
//  ImagePickerViewController.swift
//  WKImagePicker
//
//  Created by keke on 2017/2/7.
//  Copyright © 2017年 keke. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifierOne = "CameraViewCell"

private let reuseIdentifier = "ImagepickerViewCell"

let DEVICE_WIDTH : CGFloat = UIScreen.main.bounds.size.width

let DEVICE_HEIGHT: CGFloat = UIScreen.main.bounds.size.height


class ImagePickerViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource{
    
    var collectionView : UICollectionView!
    var tableView : UITableView!
    var effectview : UIVisualEffectView!
    var picturGroupsArray :NSMutableArray!
    var pictursArray :NSMutableArray!
    //计算单元格的宽度
    let itemWidth = (DEVICE_WIDTH - 1 * CGFloat(4-1))
        / CGFloat(4)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturGroupsArray = NSMutableArray()
        pictursArray = NSMutableArray()
        
        self.view.backgroundColor = UIColor.white
        
        //设置导航栏
        setNavBar()
        //设置collectionview
        setCollectionView()
        //获取相册图片
        getAllPicturGroups()
        
        
        
    }
    func setCollectionView(){
        
        //let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        //间隔
        let spacing:CGFloat = 1
        //水平间隔
        layout.minimumInteritemSpacing = spacing
        //垂直行间距
        layout.minimumLineSpacing = spacing
        //设置单元格宽度和高度
        layout.itemSize = CGSize(width:itemWidth, height:itemWidth)
        
        collectionView = UICollectionView(frame:CGRect(x:0,y:0,width:DEVICE_WIDTH,height:DEVICE_HEIGHT) , collectionViewLayout:layout)
        collectionView.collectionViewLayout = layout;
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        collectionView.register(CameraViewCell.self, forCellWithReuseIdentifier: reuseIdentifierOne)
        collectionView.register(ImagepickerViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
    func setNavBar(){
        
        
        self.title = "相机胶卷"
        
        let chooseButton = UIButton()
        chooseButton.frame = CGRect(x:0,y:0,width:44,height:44)
        chooseButton.setTitle("相册", for: UIControlState.normal)
        chooseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        chooseButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        chooseButton.addTarget(self, action: #selector(chooseButtonClick), for: UIControlEvents.touchUpInside)
        
        
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView:chooseButton), animated: true)
        
        
        
    }
    
    func chooseButtonClick(){
        
        if effectview == nil{
            setTableView()
        }else{
           UIView.animate(withDuration: 0.3, animations: {
            
            self.effectview.transform = CGAffineTransform.identity

           }, completion: { (fineshed) in
            if self.effectview != nil{
                self.effectview.removeFromSuperview()
                self.effectview = nil
            }
           })
        }
    }
    func cancelButtonClick(){
        
        self.dismiss(animated: true) {
            
        }
        
    }
    
    //获取所有相册
    func getAllPicturGroups(){
        
       let tmpPicturGroupsArray = NSMutableArray()

        //获取相机胶卷内照片
        let collectionResult1 = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        
        collectionResult1.enumerateObjects({ (object, index, stop) in
            
            tmpPicturGroupsArray.add(object)
        })
        
        // 遍历所有的自定义相册
        let collectionResult2 = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        collectionResult2.enumerateObjects({ (object, index, stop) in
            
            tmpPicturGroupsArray.add(object)
        })
        
        //从电脑导入的相册
        let collectionResult3 = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumSyncedAlbum, options: nil)
        collectionResult3.enumerateObjects({ (object, index, stop) in
            
            tmpPicturGroupsArray.add(object)
        })
        
        
        //筛选出包含有图片的相册,并把相机胶卷放在首位
        for i in 0..<tmpPicturGroupsArray.count {
            
            var assetCollection = PHAssetCollection()
            assetCollection = tmpPicturGroupsArray.object(at: i) as! PHAssetCollection
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key:"creationDate",ascending:true)]
            let fetchRuselt = PHAsset.fetchAssets(in: assetCollection, options: options)
            if ((assetCollection as AnyObject).isKind(of: PHAssetCollection().superclass!)) {
                if (fetchRuselt.firstObject != nil) {

                    if (!(assetCollection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumVideos) && !(assetCollection.assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumRecentlyAdded)){
                        
                        let isHaveVideo = isThePHAssetCollectionAllVideos(collection: assetCollection)
                        if !isHaveVideo{//如果包含有图片加入数组
                            
                            if (assetCollection as AnyObject).assetCollectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary {//相机胶卷放在首位
                                self.picturGroupsArray.insert(assetCollection, at: 0)
                                //刷新数据
                                getAllPicturInAssetCollection(collection:assetCollection)
                            }else{
                                self.picturGroupsArray.add(assetCollection)
                            }
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            
            
            
        }
        
        

    }
    
    //判断是否相簿内是否全为视频
    func isThePHAssetCollectionAllVideos(collection : PHAssetCollection) -> Bool {
        
        let tmpAssetArray = NSMutableArray()
        let assetResult = PHAsset.fetchAssets(in: collection, options: nil)
        
        for i in 0..<assetResult.count {
            var asset = PHAsset()
            asset = assetResult[i]
            //判断是否为图片
            if asset.mediaType != PHAssetMediaType.image {//不是图片 跳过
                continue
            }else{
                //是图片加入数组
                tmpAssetArray.add(asset)
            }
            
        }
        
        
        if (tmpAssetArray.count != 0 ) {
            return false
        }
        
        return true
        
        
    }
    //获取相册内所有图片,并刷新页面数据
    func getAllPicturInAssetCollection(collection : PHAssetCollection){
        
        //删除之前所有显示数据
        self.pictursArray.removeAllObjects()
        // 遍历这个相册中的所有asset
        let assetResult = PHAsset.fetchAssets(in: collection, options: nil)
        for i in 0..<assetResult.count {
            var asset = PHAsset()
            asset = assetResult[i]
            //判断是否为图片
            if asset.mediaType != PHAssetMediaType.image {//不是图片 跳过
                continue
            }else{
                //是图片加入数组
                self.pictursArray.insert(asset, at: 0)
            }
            
        }
        
        
        self.collectionView.reloadData()
        
        
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let num:Int = self.pictursArray.count
        
        return num + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell:CameraViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierOne, for: indexPath) as! CameraViewCell
            return cell
        }else{
            let cell:ImagepickerViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagepickerViewCell
            
            //获取相应位置的图片
            var asset = PHAsset()
            asset = self.pictursArray.object(at: (indexPath.row - 1)) as! PHAsset
            
            let imageOptions = PHImageRequestOptions()
            imageOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            
            //图片尺寸
            let scale = UIScreen.main.scale
            let imageSize = CGSize(width:itemWidth * scale,height:itemWidth * scale)
            
            //取出图片
            PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFill, options: imageOptions, resultHandler: { (image, nil) in
                
                cell.imageView.image = image
                
            })
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var asset = PHAsset()
        asset = self.pictursArray.object(at: (indexPath.row - 1)) as! PHAsset
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        imageOptions.isSynchronous = true
        
        //图片尺寸
        let imageSize = CGSize(width:asset.pixelWidth,height:asset.pixelHeight)
        
        //取出图片
        PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFill, options: imageOptions, resultHandler: { (image, nil) in
            
            let showC = ShowPictureViewController()
            showC.bgImage = image!
            self.navigationController?.pushViewController(showC, animated: true)
            
            
        })
        
        
    }
    
    func setTableView(){
        
        let blur = UIBlurEffect(style:UIBlurEffectStyle.dark)
        let groupViewH:CGFloat = (DEVICE_HEIGHT - 64)
        effectview = UIVisualEffectView(effect:blur)
        effectview.frame = CGRect(x:0,y:-groupViewH,width:DEVICE_WIDTH,height:groupViewH)
        self.view.addSubview(effectview)
        
        tableView = UITableView(frame:CGRect(x:0,y:0,width:DEVICE_WIDTH,height:DEVICE_HEIGHT - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alpha = 0.8;
        tableView.backgroundColor = UIColor.clear;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        effectview.addSubview(tableView)
        
        UIView.animate(withDuration: 0.3) {
            
            self.effectview.transform = CGAffineTransform(translationX: 0,y: groupViewH + 64)
        }
        
        self.tableView.reloadData()

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.picturGroupsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier="ImageGroupViewCell";
        
        let cell = ImageGroupViewCell(style: UITableViewCellStyle.`default`, reuseIdentifier:identifier)
        
        cell.setAssetCollection(assetCollection: self.picturGroupsArray.object(at: indexPath.row) as! PHAssetCollection)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       let assetCollection = self.picturGroupsArray.object(at: indexPath.row) as! PHAssetCollection
        getAllPicturInAssetCollection(collection:assetCollection)
        chooseButtonClick()

    }
    
}
class CameraViewCell: UICollectionViewCell {
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        let imageView = UIImageView(image : UIImage(named:"publish_camera"))
        imageView.frame = self.bounds
        self.addSubview(imageView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}


class ImagepickerViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        imageView.frame = self.bounds
        imageView.backgroundColor = UIColor.cyan
        self.addSubview(imageView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ImageGroupViewCell: UITableViewCell {
    
    var photoView = UIImageView()
    var photoTitleLabel = UILabel()
    var photoNumLabel = UILabel()
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = UITableViewCellSelectionStyle.none;

        
        photoView.frame = CGRect(x:15,y:15,width:50,height:50)
        photoView.layer.cornerRadius = 3
        photoView.layer.masksToBounds = true
        self.addSubview(photoView)
        
        photoTitleLabel.frame = CGRect(x:photoView.frame.maxX + 15,y:0,width:DEVICE_WIDTH - 65 - 15 - 100,height:80)
        photoTitleLabel.textColor = UIColor.white
        photoTitleLabel.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(photoTitleLabel)
        
        photoNumLabel.frame = CGRect(x:DEVICE_WIDTH - 100 - 15,y:0,width:100,height:80)
        photoNumLabel.textColor = UIColor.white
        photoNumLabel.font = UIFont.systemFont(ofSize: 14)
        photoNumLabel.textAlignment = NSTextAlignment.right
        self.addSubview(photoNumLabel)
        
        let lineView = UIView()
        lineView.frame = CGRect(x:0,y:79.5,width:DEVICE_WIDTH,height:0.5)
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.addSubview(lineView)
        
        
    }
    
    func setAssetCollection(assetCollection:PHAssetCollection){
        //去除所有图片和视频
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate",ascending:true)]
        let fetchRuselt = PHAsset.fetchAssets(in: assetCollection, options: options)
        var totalNum:NSInteger = fetchRuselt.count
        let photos = NSMutableArray()
        //挑选出所有图片
        for i in 0..<fetchRuselt.count {

            var asset = PHAsset()
            asset = fetchRuselt.object(at: i)
            
            if asset.mediaType == PHAssetMediaType.video{
                totalNum -= 1
            }else{
              photos.add(asset)
            }
            
        }
        
        self.photoTitleLabel.text = assetCollection.localizedTitle;
        
        self.photoNumLabel.text = String(photos.count)
        
        if photos.count != 0 {
            let imageOptions = PHImageRequestOptions()
            imageOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
            PHImageManager.default().requestImage(for: photos.lastObject as! PHAsset, targetSize: CGSize(width:50,height:50), contentMode: PHImageContentMode.aspectFill, options: imageOptions, resultHandler: { (image, nil) in
                
                self.photoView.image = image
                
            })
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}
