//
//  UILabel+Extension.swift
//  Weibo22
//
//  Created by Apple on 16/12/4.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit

extension UILabel {
    //  扩展UILabel的一个便利构造函数
    convenience init(fontSize: CGFloat, textColor: UIColor) {
        self.init()
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = textColor
    }
}
