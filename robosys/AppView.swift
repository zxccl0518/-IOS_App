//
//  AppView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppView: UIView,UITextFieldDelegate
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
    }
    
    lazy var tempTextField = UITextField()
    lazy var connect = RobotConnect.shareInstance()
    lazy var control = RobotControl.shareInstance()
    
    lazy var loginM = loginModel.sharedInstance
    lazy var registM = registModel.sharedInstance
    lazy var robotM = robotModel.sharedInstance
    lazy var networkM = networkModel.sharedInstance
    ///自定义headView
    /**
     TxtField:目标headView
     text:标题文字
     */
    ///备注：
    func initHeadView(text:String,imageName:String)
    {
        
        let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,150))
        addSubview(headView)
        
        headView.titleLabel.text = text

        
        guard imageName != "" else
        {
            headView.leftBtn.hidden = true
            
            return
        }
        headView.leftBtn.setImage(UIImage(named: imageName), forState: .Normal)
    }
    
    ///自定义mainheadView
    /**
     TxtField:目标headView
     text:标题文字
     */
    ///备注：
    func initMainHeadView(text:String,imageName:String)->MainHeadView
    {
        
         let headView = MainHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, 140))
        self.addSubview(headView)

        headView.titleLabel.text = text
//        headView.titleLabel.font = UIFont(name: "RTWS yueGothic Trial", size: 17)
        
        
        guard imageName != "" else
        {
            headView.leftBtn.hidden = true
            
            return headView
        }
        headView.leftBtn.setImage(UIImage(named: imageName), forState: .Normal)
        return headView
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        tempTextField = textField
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tempTextField.resignFirstResponder()
        
        for v in subviews
        {
            if v.classForCoder == AppCaptchaView.classForCoder()
            {
                v.removeFromSuperview()
            }
        }
    }

    //跳转
    func jump2AnyController(destiVC:UIViewController)
    {
        dispatch_async(dispatch_get_main_queue()) { 
            
            if let nav = self.getCurrentVC() as? UINavigationController
            {
                for vc in nav.viewControllers
                {
                    if vc.classForCoder == destiVC.classForCoder
                    {
                        nav.popToViewController(vc, animated: true)
                        return
                    }
                }
                nav.pushViewController(destiVC, animated: true)
            }
            else
            {
                let nav = self.getCurrentVC().navigationController!
                
                for vc in nav.viewControllers
                {
                    if vc.classForCoder == destiVC.classForCoder
                    {
                        nav.popToViewController(vc, animated: true)
                        return
                    }
                }
                nav.pushViewController(destiVC, animated: true)
            }
        }
    }
    //弹窗消失
    func dismiss()
    {
        if self.superview != nil
        {
            self.superview?.removeFromSuperview()
        }
    }
        
    //加边框
    func addBorder(view:UIView)
    {
        view.layer.borderColor = UIColor(red: 136/255, green: 150/255, blue: 204/255, alpha: 1).CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.backgroundColor = UIColor(red: 7/255, green: 17/255, blue: 35/255, alpha: 0.5)
    }

}
