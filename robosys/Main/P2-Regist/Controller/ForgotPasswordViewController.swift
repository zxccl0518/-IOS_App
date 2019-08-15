//
//  ForgotPasswordViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: AppViewController
{
   
    //-MARK:生命周期
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        (view as! ForgotPasswordView).timer.invalidate()
        (view as! ForgotPasswordView).timer = NSTimer()
        (view as! ForgotPasswordView).captchaBtn.setTitle("获取验证码", forState: UIControlState.Normal)
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
