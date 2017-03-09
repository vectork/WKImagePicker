//
//  ViewController.swift
//  WKImagePicker
//
//  Created by keke on 2017/2/7.
//  Copyright © 2017年 keke. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let pushButton = UIButton()
        pushButton.frame = CGRect(x:100,y:100,width:100,height:100)
        pushButton.center = self.view.center
        pushButton.setTitle("相册", for: .normal)
        pushButton.setTitleColor(UIColor.white, for: .normal)
        pushButton.backgroundColor = UIColor.cyan
        pushButton.addTarget(self, action:#selector(pushed), for: .touchUpInside)
        self.view.addSubview(pushButton)
        
        
    }

    func pushed() {

        getPHPhotoLibraryStatusBlock { (have) -> (Void) in
            
            
            DispatchQueue.main.async {
                
                let imagePickerC  = ImagePickerViewController()
                self.navigationController?.pushViewController(imagePickerC, animated: true)
             }
            
        }
       
        
        
    }
    
    //获取相册权限
    func getPHPhotoLibraryStatusBlock(succeed: ((Any?)->(Void))?){
        
        DispatchQueue.global().async {

            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined{//还没有询问是否给访问权限
                
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    
                    if authorizationStatus == PHAuthorizationStatus.authorized{//允许访问
                        succeed?(true)
                    }
                    
                })
                
            }else if ((PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.restricted) || (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied)){//不允许访问,弹框提醒开启
                

                
            }else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {//允许访问
                
                succeed?(true)

                
            }
            
        }

        
    }
    
    //没有权限弹框提醒
    func alertNotAllowVideo(){
        
        
    }

}

