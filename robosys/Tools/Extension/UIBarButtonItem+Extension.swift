//
//  UIBarButtonItem+Extension.swift
//  Weibo22
//
//  Created by Apple on 16/11/30.
//  Copyright © 2016年 Apple. All rights reserved.
//

import UIKit
//  不能提供指定构造函数在extension, 可以定义便利构造函数


extension UIBarButtonItem {
    //  提供便利构造函数
    //  给函数的参数提供默认值, 如果这个参数没有给它传值那么使用默认值nil, 如果给它传值那么使用的是传入过来的值
    convenience init(title: String, imageName: String? = nil, target: AnyObject?, action: Selector) {
        //  使用self的方式调用init构造函数
        self.init()
        
        let button = UIButton()
        //  添加点击事件
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle(title, forState: UIControlState.Normal)
        //  如果外界传入的值不为nil,那么直接设置图片
        if imageName != nil {
            button.setImage(UIImage(named: imageName!), forState: UIControlState.Normal)
        }
        //  设置文字颜色
//        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
//        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted)
//        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //  设置字体大小
        button.titleLabel?.font = UIFont.systemFontOfSize(17)
        button.sizeToFit()
        
        //  关联
        self.customView = button
        
        
        
    }

}


