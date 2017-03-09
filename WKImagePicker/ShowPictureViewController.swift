//
//  ShowPictureViewController.swift
//  WKImagePicker
//
//  Created by keke on 2017/2/9.
//  Copyright © 2017年 keke. All rights reserved.
//

import UIKit

class ShowPictureViewController: UIViewController {

    var bgImage = UIImage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let imageView = UIImageView(image:bgImage)
        
        let imageViewW:CGFloat
        let imageViewH:CGFloat
        if bgImage.size.width > DEVICE_WIDTH{
            imageViewW = DEVICE_WIDTH
            imageViewH = (DEVICE_WIDTH/bgImage.size.width) * bgImage.size.height
        }else{
            
            imageViewW = bgImage.size.width
            imageViewH = bgImage.size.height
        }
        
        imageView.frame = CGRect(x:0,y:64,width:imageViewW,height:imageViewH)
        
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        
        
    }
    

    
}
