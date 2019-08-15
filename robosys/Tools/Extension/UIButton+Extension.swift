
//
//  UIButton+Extension.swift
//  Weibo22
//
//  Created by Apple on 16/12/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit

extension UIButton {
    //  扩展按钮的一个便利构造函数
    convenience init(imageName: String? = nil, backgroundImageName: String? = nil, title: String? = nil, titleColor: UIColor? = nil, fontSize: CGFloat? = nil) {
        self.init()
        if let imgName = imageName {
            self.setImage(UIImage(named: imgName), forState: UIContr.normal)
        }
        if let bgImageName = backgroundImageName {
            self.setBackgroundImage(UIImage(named: bgImageName), forState: .normal)
        }
        if let myTitle = title {
            self.setTitle(myTitle, forState: .normal)
        }
        if let myTitleColor = titleColor {
            self.setTitleColor(myTitleColor, forState: .normal)
        }
        if let myFontSize = fontSize {
            self.titleLabel?.font = UIFont.systemFont(ofSize: myFontSize)
        }
        
    
    }

}
